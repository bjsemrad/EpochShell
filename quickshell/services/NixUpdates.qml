pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Flake update awareness, over EpochOxide's API.
//
// Structured like LocalSend.qml and Capture.qml: one socket, a small request queue, normalized
// state. Nothing here runs nix. The daemon owns the checking -- it has the timer and the cache --
// and this only asks what the last check found, which is a memory read on the other side and so
// cheap enough to poll.
//
// Checking is never automatic from here. `check()` exists for the panel's button; the schedule
// lives in the backend so it keeps running whether or not the panel has ever been opened.
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    property string flake: ""
    property bool configured: false
    property bool available: false
    property string reason: ""
    property bool checking: false
    property int checkedAt: 0
    property int lockedAt: 0
    property int updates: 0
    // Only the inputs that can move; the rest are noise on a panel.
    property var movable: []
    property var hosts: []
    property string updateCommand: ""
    property string error: ""
    property string backendError: ""
    property string status: ""

    property var _requestQueue: []
    property bool _requestInFlight: false

    readonly property bool connected: socketLoader.item !== null && socketLoader.item.connected
    readonly property bool hasUpdates: updates > 0
    readonly property string icon: "󱄅"

    // "3 hours", for a line that already says what it is measuring.
    function ago(timestamp) {
        if (!timestamp) return "never";
        const seconds = Math.max(0, Math.floor(Date.now() / 1000) - timestamp);
        const plural = (value, unit) => value === 1 ? ("1 " + unit) : (value + " " + unit + "s");
        if (seconds < 60) return "moments";
        if (seconds < 3600) return plural(Math.floor(seconds / 60), "minute");
        if (seconds < 86400) return plural(Math.floor(seconds / 3600), "hour");
        return plural(Math.floor(seconds / 86400), "day");
    }

    function shortRev(rev) {
        return String(rev || "").slice(0, 7) || "-";
    }

    function refresh() {
        apiRequest("nix.status", {}, { kind: "status" });
    }

    // Resolves every input over the network, so the panel says so while it runs.
    function check() {
        if (checking) return;
        checking = true;
        status = "Checking for updates...";
        apiRequest("nix.check", {}, { kind: "check" });
    }

    function update() {
        status = "Opening a terminal...";
        apiRequest("nix.update", {}, { kind: "run" });
    }

    function rebuild(host) {
        status = "Opening a terminal...";
        apiRequest("nix.rebuild", { host: String(host || "") }, { kind: "run" });
    }

    function applyStatus(ok, data, error) {
        if (!ok) {
            available = false;
            reason = error || "Nix update checking is unavailable";
            checking = false;
            return;
        }
        flake = String(data.flake || "");
        configured = data.configured === true;
        available = data.available === true;
        reason = String(data.reason || "");
        checking = data.checking === true;
        checkedAt = Number(data.checked_at || 0);
        lockedAt = Number(data.locked_at || 0);
        updates = Number(data.updates || 0);
        const inputs = Array.isArray(data.inputs) ? data.inputs : [];
        movable = inputs.filter(input => input.update_available === true);
        hosts = Array.isArray(data.hosts) ? data.hosts : [];
        updateCommand = String(data.update_command || "");
        error = String(data.error || "");
    }

    function applyCheck(ok, data, error) {
        checking = false;
        if (!ok) {
            status = error || "The check failed";
            return;
        }
        applyStatus(true, data, "");
        status = updates === 0 ? "Everything is current" : (updates === 1 ? "1 input can be updated" : (updates + " inputs can be updated"));
    }

    function applyRun(ok, data, error) {
        status = ok ? ("Running " + String(data.command || "") + " in a terminal") : (error || "Nothing to run");
    }

    function apiRequest(method, params, meta) {
        _requestQueue = _requestQueue.concat([{ method: method, params: params || {}, meta: meta || {} }]);
        sendNextRequest();
    }

    function sendNextRequest() {
        if (_requestInFlight || _requestQueue.length === 0) return;
        const socket = socketLoader.item;
        if (!socket || !socket.connected) return;
        _requestInFlight = true;
        const request = _requestQueue[0];
        socket.write(JSON.stringify({ type: "api", method: request.method, params: request.params, version: 1 }) + "\n");
        socket.flush();
        // A check talks to every input's host; a status read answers from memory.
        requestTimeout.interval = request.meta.kind === "check" ? 300000 : 8000;
        requestTimeout.restart();
    }

    function finishRequest() {
        requestTimeout.stop();
        _requestQueue = _requestQueue.slice(1);
        _requestInFlight = false;
        sendNextRequest();
    }

    function rebuildSocket() {
        socketLoader.active = false;
        socketLoader.active = true;
    }

    Timer {
        id: requestTimeout
        repeat: false
        onTriggered: {
            root.checking = false;
            root._requestQueue = [];
            root._requestInFlight = false;
            root.rebuildSocket();
        }
    }

    Timer {
        id: retry
        interval: 2000
        repeat: true
        running: !root.connected
        onTriggered: root.rebuildSocket()
    }

    // The backend checks on its own schedule; this only picks up what it found. A minute is often
    // enough to notice a check that finished, and costs nothing on the daemon side.
    Timer {
        id: poll
        interval: 60000
        repeat: true
        running: root.connected
        triggeredOnStart: true
        onTriggered: root.refresh()
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
                    root._requestInFlight = false;
                    return;
                }
                root.backendError = "";
                root.sendNextRequest();
                root.refresh();
            }

            onError: function (error) {
                root.backendError = "Cannot reach EpochOxide";
            }

            parser: SplitParser {
                onRead: function (line) {
                    const request = root._requestQueue.length > 0 ? root._requestQueue[0] : null;
                    if (!request) return;
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("nix epochoxide parse error:", e, line);
                        root.finishRequest();
                        return;
                    }
                    const ok = response.ok !== false;
                    const data = response.data || {};
                    const error = response.error || data.message || "";
                    // "unavailable" means no flake is configured, which is a setting rather than a
                    // broken backend; the panel says so itself.
                    if (ok) root.backendError = "";
                    else if (data.code !== "unavailable") root.backendError = error;
                    if (request.meta.kind === "status") {
                        root.applyStatus(ok, data, error);
                    } else if (request.meta.kind === "check") {
                        root.applyCheck(ok, data, error);
                    } else if (request.meta.kind === "run") {
                        root.applyRun(ok, data, error);
                    }
                    root.finishRequest();
                }
            }
        }
    }
}
