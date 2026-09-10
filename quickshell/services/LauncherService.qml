pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string query: ""
    property alias results: resultModel

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"
    readonly property string allPrefix: "*"
    property bool searching: false
    // Everything below is filled in from EpochOxide's `providers` response; nothing about the
    // provider set or its query prefixes is known ahead of time.
    property var providerCapabilities: []
    property var availableProviders: []
    property var providersByPrefix: ({})
    readonly property string defaultProviders: availableProviders.join(",")
    readonly property bool backendConnected: socketLoader.item !== null && socketLoader.item.connected
    property string backendError: ""
    property bool _providersLoaded: false
    // Whether the backend has answered with its provider list yet. Callers that need to know
    // whether a provider has a prefix have to wait for this, or they will decide it has none.
    readonly property bool providersLoaded: _providersLoaded

    readonly property int defaultAppsTTL: 600000
    property bool _defaultAppsLoaded: false
    property int _defaultAppsStamp: 0
    property var _defaultAppsCache: []
    property bool _silentRefresh: false
    property var _requestQueue: []
    property bool _requestInFlight: false
    property var _streamBatches: ({})

    signal providersUpdated()
    signal resultsUpdated()

    ListModel {
        id: resultModel
    }

    // A provider the launcher is pinned to, regardless of what the query text says.
    //
    // Routing is otherwise entirely by prefix, which leaves a provider with no prefix -- a custom
    // menu, say -- unreachable: there is nothing to type that scopes to it. Pinning is how the
    // provider list and `epochctl launcher provider <name>` reach one.
    property string scope: ""

    function setQuery(text) {
        query = text;
        debounceTimer.restart();
    }

    function setScope(name) {
        scope = String(name || "");
        query = "";
        debounceTimer.restart();
    }

    function isMathQuery(text) {
        const t = String(text).trim();
        return /[0-9].{0,4}[+\-*/^%()]|[+\-*/^%()].{0,4}[0-9]/.test(t);
    }

    function providerAvailable(provider) {
        // Optimistic until the first Providers round-trip lands: on a fresh launcher open the
        // prefix routing below (e.g. "/" -> files) would otherwise always lose the race against
        // that async response and silently fall back to searching apps with a leading "/"/"@"/etc.
        // still in the query text.
        if (!root._providersLoaded) return true;
        const base = String(provider).split(":")[0];
        return availableProviders.indexOf(base) !== -1;
    }

    function enabledProviders(providers) {
        return String(providers).split(",").filter(p => root.providerAvailable(p)).join(",");
    }

    function providerForPrefix(prefix) {
        if (prefix in providersByPrefix) return providersByPrefix[prefix];
        return prefix === root.allPrefix ? root.enabledProviders(root.defaultProviders) : "";
    }

    // Longest match wins, mirroring EpochOxide's own prefix routing (prefixes are arbitrary
    // strings in its config, not necessarily single characters).
    function prefixFor(text) {
        const s = String(text);
        let best = "";
        for (const prefix in providersByPrefix) {
            if (prefix.length > best.length && s.startsWith(prefix)) best = prefix;
        }
        if (best.length === 0 && s.startsWith(root.allPrefix)) best = root.allPrefix;
        return best;
    }

    function capabilityFor(name) {
        for (const cap of providerCapabilities) {
            if (cap.name === name) return cap;
        }
        return null;
    }

    function prettyName(name) {
        const cap = root.capabilityFor(name);
        return cap ? cap.namePretty : name;
    }

    function prefixForProvider(name) {
        const cap = root.capabilityFor(name);
        return cap && cap.prefixes.length > 0 ? cap.prefixes[0] : "";
    }

    function applyProviders(list) {
        const caps = [];
        const names = [];
        const byPrefix = {};
        for (const raw of list) {
            if (!raw) continue;
            const name = typeof raw === "string" ? raw : String(raw.name || "");
            if (name.length === 0) continue;
            const prefixes = (Array.isArray(raw.prefixes) ? raw.prefixes : []).filter(p => typeof p === "string" && p.length > 0);
            caps.push({
                name: name,
                namePretty: String(raw.name_pretty || name),
                description: String(raw.description || ""),
                icon: String(raw.icon || ""),
                prefixes: prefixes,
                supportsQuery: raw.supports_query !== false
            });
            names.push(name);
            for (const prefix of prefixes) {
                if (!(prefix in byPrefix)) byPrefix[prefix] = name;
            }
        }
        root.providerCapabilities = caps;
        root.availableProviders = names;
        root.providersByPrefix = byPrefix;
        root._providersLoaded = true;
    }

    // QLocalSocket::LocalSocketError values; anything else falls through to the generic text.
    function socketErrorText(error) {
        switch (error) {
        case 0: return "EpochOxide refused the connection";
        case 1: return "EpochOxide closed the connection";
        case 2: return "EpochOxide is not running";
        case 3: return "No permission to open the EpochOxide socket";
        case 5: return "EpochOxide timed out";
        default: return "Cannot reach EpochOxide";
        }
    }

    // A Socket that failed to connect stays dead: reassigning `connected`/`path` on it is a no-op,
    // so recovering from a stopped backend means building a new one.
    function rebuildSocket() {
        socketLoader.active = false;
        socketLoader.active = true;
    }

    function sendNextRequest() {
        if (_requestInFlight || _requestQueue.length === 0) return;
        const socket = socketLoader.item;
        if (!socket || !socket.connected) return;
        _requestInFlight = true;
        const request = _requestQueue[0];
        if (request.payload.type === "query") root._streamBatches = {};
        socket.write(JSON.stringify(request.payload) + "\n");
        socket.flush();
        requestTimeout.restart();
    }

    function enqueueRequest(kind, payload, meta) {
        if (kind === "query") {
            const active = _requestInFlight && _requestQueue.length > 0 ? [_requestQueue[0]] : [];
            _requestQueue = active.concat(_requestQueue.slice(active.length).filter(r => r.kind !== "query"));
        }
        _requestQueue = _requestQueue.concat([{ kind: kind, payload: payload, meta: meta || {} }]);
        sendNextRequest();
    }

    // Multi-provider queries stream back one batch per provider as each finishes, instead of
    // waiting for the slowest provider (e.g. a large file index) before showing anything.
    function startQuery(providers, q) {
        const limit = q === "" ? 30 : 10;
        const silent = root._silentRefresh;
        root._silentRefresh = false;
        const meta = { providers: providers, query: q, limit: limit, silent: silent };
        const providerList = String(providers).split(",").filter(p => p.length > 0);
        enqueueRequest("query", { type: "query", providers: providerList, query: q, limit: limit, exact: false, stream: providerList.length > 1 }, meta);
        if (!silent) root.searching = true;
    }

    function isDefaultAppsQuery(meta) {
        return meta.providers === "apps" && meta.query === "" && meta.limit === 30;
    }

    function showCachedApps() {
        searching = false;
        resultModel.clear();
        for (const it of _defaultAppsCache) resultModel.append(it);
        root.resultsUpdated();
    }

    function applyResults(items) {
        resultModel.clear();
        for (const it of items) resultModel.append(it);
        root.resultsUpdated();
    }

    function runQuery() {
        debounceTimer.stop();
        const raw = query;
        // Anything starting with ";" is the provider list, which the overlay draws from its own
        // model -- including ";cap", which filters it. Running a search for that text would put
        // app results underneath a list that is not showing them.
        if (raw.startsWith(";")) {
            resultModel.clear();
            root.resultsUpdated();
            return;
        }
        const prefix = root.prefixFor(raw);
        let providers;
        let q;
        const prefixedProvider = root.providerForPrefix(prefix);
        // A typed prefix wins over a pinned provider: it is how someone moves from one provider to
        // another without going back out first, and it is unambiguous about what they meant.
        if (prefixedProvider.length > 0) {
            providers = prefixedProvider;
            q = raw.slice(prefix.length);
        } else if (root.scope.length > 0) {
            // Pinned: the text is all query, with no prefix to strip. The "*" scope is the same
            // sentinel the prefix routing uses, and means every provider rather than one named "*".
            providers = root.scope === root.allPrefix
                ? root.enabledProviders(root.defaultProviders)
                : root.scope;
            q = raw.trim();
        } else if (root.providerAvailable("calc") && root.isMathQuery(raw)) {
            providers = "calc";
            q = raw.trim();
        } else {
            providers = "apps";
            q = raw.trim();
        }
        if (providers === "apps" && q === "" && _defaultAppsLoaded) {
            showCachedApps();
            if (Date.now() - _defaultAppsStamp >= defaultAppsTTL) {
                _silentRefresh = true;
                startQuery(providers, q);
            }
            return;
        }
        startQuery(providers, q);
    }

    function activate(provider, identifier, action) {
        enqueueRequest("activate", { type: "activate", provider: provider, identifier: identifier, action: action || "", query: query, arguments: "" });
    }

    function refreshProviders() {
        // While the backend is down requests sit in the queue instead of being written, so don't
        // stack up a providers refresh per reconnect attempt. The queued one still has to be
        // flushed: the first refresh is requested on component completion, before the socket has
        // connected, so returning here without a send left the provider list empty until some
        // other request (the first query the user typed) happened to drain the queue.
        if (_requestQueue.some(request => request.kind === "providers")) {
            sendNextRequest();
            return;
        }
        enqueueRequest("providers", { type: "providers" });
    }

    function normalizeItem(obj) {
        const item = obj.item || obj;
        if (!item) return null;
        return {
            provider: item.provider || "",
            identifier: item.identifier || "",
            text: item.text || "",
            subtext: item.subtext || "",
            icon: item.icon || "",
            score: item.score || 0,
            action: (item.actions && item.actions.length > 0) ? item.actions[0] : "",
            preview: item.preview || "",
            previewType: item.preview_type || ""
        };
    }

    // A single-provider query comes back as a plain item array rather than per-provider batches.
    function applyQueryResult(data, meta) {
        root.searching = false;
        const items = [];
        try {
            const arr = Array.isArray(data) ? data : [];
            for (const obj of arr) {
                const item = normalizeItem(obj);
                if (!item) continue;
                items.push(item);
                if (items.length >= meta.limit) break;
            }
        } catch (e) {
            console.log("launcher query parse error:", e);
        }
        root.applyResults(items);
    }

    function mergedStreamItems(limit) {
        let merged = [];
        for (const provider in root._streamBatches) merged = merged.concat(root._streamBatches[provider]);
        merged.sort((a, b) => b.score - a.score || (a.text < b.text ? -1 : a.text > b.text ? 1 : 0));
        return merged.slice(0, limit);
    }

    // Each provider's items already arrive weighted/sorted/truncated per-provider from the
    // server; merge-and-truncate again here to apply the overall result limit across providers.
    function mergeQueryBatch(provider, rawItems, meta) {
        try {
            const batches = root._streamBatches;
            batches[String(provider)] = (rawItems || []).map(normalizeItem).filter(i => i);
            root._streamBatches = batches;
        } catch (e) {
            console.log("launcher query batch parse error:", e);
            return;
        }
        root.applyResults(root.mergedStreamItems(meta.limit));
    }

    function finishStreamedQuery(meta) {
        root.searching = false;
        const items = root.mergedStreamItems(meta.limit);
        root._streamBatches = {};
        if (root.isDefaultAppsQuery(meta)) {
            root._defaultAppsCache = items;
            root._defaultAppsStamp = Date.now();
            root._defaultAppsLoaded = true;
        }
        root.applyResults(items);
    }

    function finishRequest() {
        requestTimeout.stop();
        root._requestQueue = root._requestQueue.slice(1);
        root._requestInFlight = false;
        root.sendNextRequest();
    }

    Timer {
        id: debounceTimer
        interval: root.providerForPrefix(root.prefixFor(root.query)) === "files" ? 40 : 150
        repeat: false
        onTriggered: root.runQuery()
    }

    // Generous enough for a provider that has to go and generate its results (a menu whose entries
    // come from a script), while still catching a backend that has gone quiet.
    Timer {
        id: requestTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            root._requestQueue = [];
            root._requestInFlight = false;
            root._streamBatches = {};
            root.searching = false;
            console.log("launcher epochoxide timeout:", root.socketPath);
            // Only a live connection can be "not responding"; otherwise keep the socket's own
            // error, which says something more useful (not running, refused, no permission).
            if (root.backendConnected) root.backendError = "EpochOxide is not responding";
            root.rebuildSocket();
        }
    }

    // The backend is a user service that can be stopped, crash, or come up after the shell;
    // keep rebuilding the socket so the launcher recovers on its own once it is back.
    Timer {
        id: retryTimer
        interval: 2000
        repeat: true
        running: !root.backendConnected
        onTriggered: root.rebuildSocket()
    }

    Loader {
        id: socketLoader
        active: true

        sourceComponent: Socket {
            id: epochoxideSocket
            path: root.socketPath
            connected: true

            onConnectionStateChanged: {
                if (!epochoxideSocket.connected) {
                    root._requestQueue = [];
                    root._requestInFlight = false;
                    root._streamBatches = {};
                    root.searching = false;
                    return;
                }
                root.backendError = "";
                root.refreshProviders();
            }

            onError: function (error) {
                root.backendError = root.socketErrorText(error);
            }

            parser: SplitParser {
                onRead: function (line) {
                    root.backendError = "";
                    const request = root._requestQueue.length > 0 ? root._requestQueue[0] : null;
                    if (!request) return;
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("launcher epochoxide parse error:", e, line);
                        return;
                    }
                    if (response.ok === false) {
                        console.log("launcher epochoxide error:", response.error || "request failed");
                        root.finishRequest();
                        return;
                    }
                    if (request.kind === "providers") {
                        root.applyProviders(Array.isArray(response.data) ? response.data : []);
                        root.providersUpdated();
                        root.finishRequest();
                        return;
                    }
                    if (request.kind === "query") {
                        const data = response.data;
                        if (Array.isArray(data)) {
                            root.applyQueryResult(data, request.meta);
                            root.finishRequest();
                            return;
                        }
                        if (data && data.type === "query_batch") {
                            root.mergeQueryBatch(data.provider, data.items, request.meta);
                            requestTimeout.restart();
                            return;
                        }
                        root.finishStreamedQuery(request.meta);
                        root.finishRequest();
                        return;
                    }
                    root.finishRequest();
                }
            }
        }
    }

    Component.onCompleted: root.refreshProviders()
}
