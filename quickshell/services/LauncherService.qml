pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string query: ""
    property alias results: resultModel

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"
    readonly property string defaultProviders: "apps,windows,clipboard,calc,files"
    readonly property var providersByPrefix: ({
        "/": "files",
        ":": "clipboard",
        "!": "windows",
        "=": "calc",
        "?": "menus:keybinds",
        "*": defaultProviders
    })
    property bool searching: false
    property var availableProviders: []
    property bool _providersLoaded: false

    readonly property int defaultAppsTTL: 600000
    property bool _defaultAppsLoaded: false
    property int _defaultAppsStamp: 0
    property var _defaultAppsCache: []
    property bool _silentRefresh: false
    property var _requestQueue: []
    property bool _requestInFlight: false
    property var _streamBatches: ({})

    signal providersUpdated()

    ListModel {
        id: resultModel
    }

    function setQuery(text) {
        query = text;
        debounceTimer.restart();
    }

    function isMathQuery(text) {
        const t = String(text).trim();
        return /[0-9].{0,4}[+\-*/^%()]|[+\-*/^%()].{0,4}[0-9]/.test(t);
    }

    function providerAvailable(provider) {
        // Optimistic until the first Providers round-trip lands: on a fresh launcher open the
        // prefix routing below (e.g. "/" -> files) would otherwise always lose the race against
        // that async response and silently fall back to searching apps with a leading "/"/":"/etc.
        // still in the query text.
        if (!root._providersLoaded) return true;
        const base = String(provider).split(":")[0];
        return availableProviders.indexOf(base) !== -1;
    }

    function enabledProviders(providers) {
        return String(providers).split(",").filter(p => root.providerAvailable(p)).join(",");
    }

    function providerForPrefix(prefix) {
        if (!(prefix in providersByPrefix)) return "";
        const providers = providersByPrefix[prefix];
        return prefix === "*" ? root.enabledProviders(providers) : providers;
    }

    function sendNextRequest() {
        if (_requestInFlight || _requestQueue.length === 0) return;
        _requestInFlight = true;
        const request = _requestQueue[0];
        if (request.payload.type === "query") root._streamBatches = {};
        epochoxideSocket.write(JSON.stringify(request.payload) + "\n");
        epochoxideSocket.flush();
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

    // Real (non-menu) queries stream back one batch per provider as each finishes, instead of
    // waiting for the slowest provider (e.g. a large file index) before showing anything.
    function startQuery(providers, q) {
        const limit = q === "" ? 30 : 10;
        const silent = root._silentRefresh;
        root._silentRefresh = false;
        const meta = { providers: providers, query: q, limit: limit, silent: silent };
        const menuParts = String(providers).split(":");
        if (menuParts[0] === "menus" && menuParts.length > 1) {
            enqueueRequest("query", { type: "menu", menu: menuParts[1] }, meta);
        } else {
            const providerList = String(providers).split(",").filter(p => p.length > 0);
            enqueueRequest("query", { type: "query", providers: providerList, query: q, limit: limit, exact: false, stream: providerList.length > 1 }, meta);
        }
        if (!silent) root.searching = true;
    }

    function isDefaultAppsQuery(meta) {
        return meta.providers === "apps" && meta.query === "" && meta.limit === 30;
    }

    function showCachedApps() {
        searching = false;
        resultModel.clear();
        for (const it of _defaultAppsCache) resultModel.append(it);
    }

    function applyResults(items) {
        resultModel.clear();
        for (const it of items) resultModel.append(it);
    }

    function runQuery() {
        debounceTimer.stop();
        const raw = query;
        if (raw === ";") {
            resultModel.clear();
            return;
        }
        const first = raw.length > 0 ? raw[0] : "";
        let providers;
        let q;
        const prefixedProvider = root.providerForPrefix(first);
        if (prefixedProvider.length > 0) {
            providers = prefixedProvider;
            q = raw.slice(1);
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

    // Menu sub-queries get a plain item array back (no batching on the server side); filtered
    // client-side against the typed text since Menu requests carry no query of their own.
    function applyQueryResult(data, meta) {
        root.searching = false;
        const items = [];
        try {
            const arr = Array.isArray(data) ? data : [];
            const needle = meta.providers && String(meta.providers).startsWith("menus:") ? String(meta.query || "").toLowerCase() : "";
            for (const obj of arr) {
                const item = normalizeItem(obj);
                if (!item) continue;
                if (needle.length > 0 && (item.text + " " + item.subtext).toLowerCase().indexOf(needle) === -1) continue;
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
        interval: query.startsWith("/") ? 40 : 150
        repeat: false
        onTriggered: root.runQuery()
    }

    Timer {
        id: requestTimeout
        interval: 1500
        repeat: false
        onTriggered: {
            root._requestQueue = [];
            root._requestInFlight = false;
            root._streamBatches = {};
            root.searching = false;
            console.log("launcher epochoxide timeout:", root.socketPath);
            epochoxideSocket.connected = false;
            epochoxideSocket.connected = true;
            reconnectTimer.restart();
        }
    }

    Timer {
        id: reconnectTimer
        interval: 200
        repeat: false
        onTriggered: root.refreshProviders()
    }

    Socket {
        id: epochoxideSocket
        path: root.socketPath
        connected: true

        parser: SplitParser {
            onRead: function (line) {
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
                    const providers = Array.isArray(response.data) ? response.data.map(p => p.name || p).filter(p => p.length > 0) : [];
                    root.availableProviders = providers;
                    root._providersLoaded = true;
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

    Component.onCompleted: root.refreshProviders()
}
