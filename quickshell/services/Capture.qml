pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen capture, over EpochOxide's API.
//
// Structured like LocalSend.qml: one socket, a small request queue, and normalized state. Nothing
// here knows what takes the picture -- grim, slurp, the clipboard and the notification all live in
// the backend, and this only says what to capture and what to do with it afterwards.
//
// One rule shapes the whole file: the shell must not be in the shot. Every capture closes the
// panels first, and the modes that do not stop to ask the user for a selection are given a short
// delay so the compositor has actually finished drawing without them.
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    // Where shots land, and whether this compositor can hand over a window rectangle. Both come
    // from capture.status rather than being assumed here.
    property string directory: ""
    property bool windowCapture: false
    property bool available: false
    property string unavailableReason: ""

    // What to do with a shot. Seeded from the backend's configured defaults, then owned by the
    // panel's switches for the rest of the session.
    property bool copyToClipboard: true
    property bool saveToDisk: true
    property bool includeCursor: false

    property bool busy: false
    property string status: ""
    property string lastPath: ""
    property string backendError: ""

    property var _requestQueue: []
    property bool _requestInFlight: false

    readonly property bool connected: socketLoader.item !== null && socketLoader.item.connected
    readonly property string icon: "󰄀"

    // How long to wait after the panels are told to close before a mode that asks the user
    // nothing fires. Long enough for the compositor to draw a frame without them, short enough
    // that it still feels like the click took the picture.
    readonly property real settleDelay: 0.4

    function fileName(path) {
        const value = String(path || "");
        const index = value.lastIndexOf("/");
        return index >= 0 ? value.slice(index + 1) : value;
    }

    function refresh() {
        apiRequest("capture.status", {}, { kind: "status" });
    }

    // mode is one of region, window, fullscreen, all. `select` asks the user to click a window
    // instead of taking the focused one.
    function shoot(mode, select) {
        if (busy) return;
        const interactive = mode === "region" || (mode === "window" && select === true);
        busy = true;
        status = interactive ? "Waiting for a selection..." : "Taking a screenshot...";
        lastPath = "";
        // Nothing should be looking at a panel while the screen is captured, least of all the
        // camera.
        PopupManager.closeAll();
        apiRequest("capture.screenshot", {
            mode: String(mode),
            select: select === true,
            cursor: root.includeCursor,
            copy: root.copyToClipboard,
            save: root.saveToDisk,
            delay: interactive ? 0 : root.settleDelay
        }, { kind: "screenshot", mode: String(mode) });
    }

    function setCopyToClipboard(value) {
        copyToClipboard = value === true;
        // A shot that is neither kept nor copied is thrown away the moment it is taken, so the
        // other switch takes over rather than letting both be off.
        if (!copyToClipboard && !saveToDisk) saveToDisk = true;
    }

    function setSaveToDisk(value) {
        saveToDisk = value === true;
        if (!copyToClipboard && !saveToDisk) copyToClipboard = true;
    }

    function setIncludeCursor(value) {
        includeCursor = value === true;
    }

    function applyStatus(ok, data, error) {
        if (!ok) {
            available = false;
            unavailableReason = error || "Capture is unavailable";
            return;
        }
        directory = String(data.directory || "");
        windowCapture = data.window_capture === true;
        // capture.status answers even when the group cannot run, which is exactly when the tool
        // list matters: a missing required tool is what makes capture unavailable.
        const tools = Array.isArray(data.tools) ? data.tools : [];
        const missing = tools.filter(tool => tool.required === true && !tool.path);
        available = missing.length === 0;
        unavailableReason = available ? "" : (missing.map(tool => tool.name).join(", ") + " is not installed");
        if (status.length === 0 && !available) status = unavailableReason;
    }

    function applyShot(ok, data, error) {
        busy = false;
        if (!ok) {
            status = error || "Screenshot failed";
            return;
        }
        // Escape is a decision, not a failure. Say nothing louder than that.
        if (data.cancelled === true) {
            status = "Cancelled";
            return;
        }
        lastPath = String(data.path || "");
        const where = data.saved === true ? ("Saved " + root.fileName(lastPath)) : "Copied to the clipboard";
        const also = data.saved === true && data.copied === true ? ", copied" : "";
        status = where + also;
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
        // A selection waits on a person deciding what to capture, which has no upper bound worth
        // guessing; a status query answers from memory.
        requestTimeout.interval = request.meta.kind === "screenshot" ? 300000 : 8000;
        requestTimeout.restart();
    }

    function finishRequest() {
        requestTimeout.stop();
        _requestQueue = _requestQueue.slice(1);
        _requestInFlight = false;
        sendNextRequest();
    }

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

    function rebuildSocket() {
        socketLoader.active = false;
        socketLoader.active = true;
    }

    Timer {
        id: requestTimeout
        repeat: false
        onTriggered: {
            const request = root._requestQueue.length > 0 ? root._requestQueue[0] : null;
            root.busy = false;
            if (request && request.meta.kind === "screenshot") {
                root.status = "The screenshot never came back";
            } else {
                root.backendError = "EpochOxide is not responding";
            }
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
                    root.busy = false;
                    return;
                }
                root.backendError = "";
                root.sendNextRequest();
                root.refresh();
            }

            onError: function (error) {
                root.backendError = root.socketErrorText(error);
            }

            parser: SplitParser {
                onRead: function (line) {
                    const request = root._requestQueue.length > 0 ? root._requestQueue[0] : null;
                    if (!request) return;
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("capture epochoxide parse error:", e, line);
                        root.finishRequest();
                        return;
                    }
                    const ok = response.ok !== false;
                    const data = response.data || {};
                    const error = response.error || data.message || "";
                    // "unavailable" is a machine without grim, not a broken connection. The panel
                    // already says which tool is missing, so it must not also go red as though
                    // the backend had fallen over.
                    if (ok) root.backendError = "";
                    else if (data.code !== "unavailable") root.backendError = error;
                    if (request.meta.kind === "status") {
                        root.applyStatus(ok, data, error);
                    } else if (request.meta.kind === "screenshot") {
                        root.applyShot(ok, data, error);
                    }
                    root.finishRequest();
                }
            }
        }
    }
}
