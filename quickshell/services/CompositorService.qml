pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Normalized compositor state, streamed from EpochOxide.
//
// Nothing here knows what compositor is running. EpochOxide watches Hyprland's event socket or
// niri's event stream, maps what it finds onto one shape, and pushes a whole snapshot whenever it
// changes; this service holds the subscription and republishes it to the bar. Raw compositor
// payloads and dispatch strings deliberately do not appear in QML.
//
// While EpochOxide is unreachable the state stays empty rather than falling back to a
// compositor-specific path, and the subscription reconnects on its own once it is back.
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    // Which backend answered, e.g. "hypr" or "niri". Empty until the first snapshot lands.
    property string backend: ""
    property var windows: []
    property var workspaces: []
    property var monitors: []
    property var activeWindow: null

    readonly property bool isHyprland: backend === "hypr"
    readonly property bool isNiri: backend === "niri"
    readonly property string activeWindowClass: activeWindow ? String(activeWindow.app_id || "") : ""
    readonly property bool connected: subscription.item !== null && subscription.item.connected
    property string backendError: ""

    signal stateUpdated

    function applySnapshot(data) {
        root.backend = String(data.backend || "");
        root.windows = Array.isArray(data.windows) ? data.windows : [];
        root.workspaces = Array.isArray(data.workspaces) ? data.workspaces : [];
        root.monitors = Array.isArray(data.monitors) ? data.monitors : [];
        root.activeWindow = data.active_window || null;
        root.backendError = "";
        root.stateUpdated();
    }

    function clearState() {
        root.backend = "";
        root.windows = [];
        root.workspaces = [];
        root.monitors = [];
        root.activeWindow = null;
        root.stateUpdated();
    }

    // --- Queries -----------------------------------------------------------------

    function windowsForWorkspace(name) {
        return root.windows.filter(window => String(window.workspace) === String(name));
    }

    function workspaceByName(name) {
        return root.workspaces.find(workspace => String(workspace.name) === String(name)) || null;
    }

    // Chromium web apps report classes like "brave-gmail.com__-Default"; a prefix match is what
    // the icon lookup already relies on, so window matching uses the same rule.
    function findWindow(match) {
        const needle = String(match || "").toLowerCase();
        if (needle.length === 0) return null;
        return root.windows.find(window => {
            const appId = String(window.app_id || "").toLowerCase();
            return appId === needle || appId.indexOf(needle) !== -1;
        }) || null;
    }

    // --- Actions -----------------------------------------------------------------

    function focusWorkspace(id) {
        root.call("compositor.focusWorkspace", { id: String(id) });
    }

    function focusWindow(id) {
        root.call("compositor.focusWindow", { id: String(id) });
    }

    function closeWindow(id) {
        root.call("compositor.closeWindow", { id: String(id) });
    }

    function focusWindowByClass(windowClass) {
        const window = root.findWindow(windowClass);
        if (window) root.focusWindow(window.id);
    }

    // Kept as a distinct name because callers pass an application name rather than a window class;
    // the normalized app_id makes both the same lookup now.
    function focusWindowByAppName(appName) {
        root.focusWindowByClass(appName);
    }

    function logout() {
        //TODO
    }

    // --- EpochOxide plumbing -----------------------------------------------------

    property var _pending: []

    function call(method, params) {
        root._pending = root._pending.concat([{ type: "api", method: method, params: params || {} }]);
        root.flush();
    }

    function flush() {
        const socket = actions.item;
        if (!socket || !socket.connected || root._pending.length === 0) return;
        for (const request of root._pending) {
            socket.write(JSON.stringify(request) + "\n");
        }
        socket.flush();
        root._pending = [];
    }

    // A Socket that failed to connect stays dead, so recovering from a stopped backend means
    // building a new one. Same approach as LauncherService.
    function rebuild() {
        subscription.active = false;
        subscription.active = true;
        actions.active = false;
        actions.active = true;
    }

    Timer {
        id: retry
        interval: 2000
        repeat: true
        running: !root.connected
        onTriggered: root.rebuild()
    }

    Loader {
        id: subscription
        active: true

        sourceComponent: Socket {
            path: root.socketPath
            connected: true

            onConnectionStateChanged: {
                if (connected) {
                    write(JSON.stringify({ type: "api", method: "compositor.subscribe" }) + "\n");
                    flush();
                } else {
                    root.clearState();
                }
            }

            onError: function (error) {
                root.backendError = "Cannot reach EpochOxide";
            }

            parser: SplitParser {
                onRead: function (line) {
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("compositor: unparseable response:", e);
                        return;
                    }
                    if (response.ok === false) {
                        root.backendError = String(response.error || "compositor subscription failed");
                        return;
                    }
                    const data = response.data;
                    if (!data || data.type === "subscribed") return;
                    root.applySnapshot(data);
                }
            }
        }
    }

    // Actions need their own connection: the subscription's is held open by the stream.
    Loader {
        id: actions
        active: true

        sourceComponent: Socket {
            path: root.socketPath
            connected: true

            onConnectionStateChanged: {
                if (connected) root.flush();
            }

            parser: SplitParser {
                onRead: function (line) {
                    try {
                        const response = JSON.parse(line);
                        if (response.ok === false) {
                            console.log("compositor action failed:", response.error);
                        }
                    } catch (e) {
                        console.log("compositor: unparseable action response:", e);
                    }
                }
            }
        }
    }

    function iconMatch(field, key) {
        return field.toLowerCase() !== "" && key.toLowerCase().indexOf(field.toLowerCase()) !== -1;
    }

    function getDesktopEntry(app) {
        let entry = DesktopEntries.byId(app) || DesktopEntries.heuristicLookup(app);
        if (!entry) {
            if (app.startsWith("brave-")) {
                const k2 = app.replace(/.com__-Default$/, "").replace(/.com-Default$/, "").replace(/brave-/, "").replace(/\./, "");
                entry = DesktopEntries.heuristicLookup(k2);
            }
            if (app.startsWith("chrome-")) {
                const k2 = app.replace(/.com__-Default$/, "").replace(/.com-Default$/, "").replace(/chrome-/, "").replace(/\./, "");
                entry = DesktopEntries.heuristicLookup(k2);
            }
        }

        if (!entry) {
            for (let i = 0; i < DesktopEntries.applications.values.length; i++) {
                const e = DesktopEntries.applications.values[i];
                if (iconMatch(e.name, app) || iconMatch(e.startupClass, app) || iconMatch(e.id, app)) {
                    entry = e;
                    break;
                }
            }
        }

        if (!entry) entry = findWebappEntry(app);
        return entry;
    }

    function findWebappEntry(app) {
        const clean = String(app || "")
            .toLowerCase()
            .replace(/^brave-/, "")
            .replace(/^chrome-/, "")
            .replace(/^chromium-/, "")
            .replace(/^firefox-/, "")
            .replace(/^vivaldi-/, "")
            .replace(/^edge-/, "")
            .replace(/__-?Default$/, "")
            .replace(/\.desktop$/, "")
            .replace(/-Default$/, "");
        const tokens = clean.split(/[\-.]+/).filter(t => t.length >= 3);
        if (tokens.length === 0) return null;

        let best = null;
        let bestScore = 0;
        for (let i = 0; i < DesktopEntries.applications.values.length; i++) {
            const e = DesktopEntries.applications.values[i];
            const fields = [String(e.name || ""), String(e.id || ""), String(e.startupClass || "")].join(" ").toLowerCase();
            if (fields.length === 0) continue;
            let score = 0;
            for (let t = 0; t < tokens.length; t++) {
                if (fields.indexOf(tokens[t]) !== -1) score += 1;
            }
            if (score > bestScore) {
                bestScore = score;
                best = e;
            }
        }

        return bestScore >= 2 ? best : null;
    }

    function getDesktopIcon(entry) {
        if (entry?.icon) {
            const icon = String(entry.icon);

            if (icon.startsWith("/") || icon.startsWith("file:") || icon.includes("/")) {
                return icon.startsWith("file:") ? icon : ("file://" + icon);
            }

            const p = Quickshell.iconPath(icon, "");
            if (p && p.length > 0 && p.indexOf("application-x-executable") === -1)
                return p;
        }

        return "";
    }
}
