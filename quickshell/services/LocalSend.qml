pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// LocalSend devices and transfers, over EpochOxide's API.
//
// Structured like Tailscale.qml: one socket, a small request queue, and normalized state. Nothing
// here knows the LocalSend protocol -- discovery, TLS pinning and the upload handshake all live in
// the backend.
//
// Discovery is not continuous. It announces and waits for answers, so it runs when the panel is
// opened or refreshed rather than on a timer, which would put a multicast burst on the network
// every few seconds for a panel nobody is looking at.
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    // each row: { alias, fingerprint, deviceModel, deviceType, ip, port, protocol }
    property var devices: []
    property bool scanning: false
    property bool scanned: false
    property string backendError: ""

    property string selectedFile: ""
    property bool sendingFile: false
    property string sendStatus: ""
    property string sendTarget: ""

    property var _requestQueue: []
    property bool _requestInFlight: false

    readonly property bool connected: socketLoader.item !== null && socketLoader.item.connected
    readonly property bool hasDevices: devices.length > 0
    readonly property string icon: "󰒍"

    function fileName(path) {
        const value = String(path || "");
        const index = value.lastIndexOf("/");
        return index >= 0 ? value.slice(index + 1) : value;
    }

    function pathFromUrl(value) {
        let path = String(value || "");
        if (path.startsWith("file://")) {
            path = path.slice(7);
            try {
                path = decodeURIComponent(path);
            } catch (e) {
            }
        }
        return path;
    }

    function selectFile(value) {
        const path = pathFromUrl(value);
        if (path.length === 0) return;
        selectedFile = path;
        sendStatus = "Pick a device to send " + fileName(path);
    }

    function clearSelectedFile() {
        selectedFile = "";
        sendStatus = "";
        sendTarget = "";
    }

    function refresh() {
        if (scanning) return;
        scanning = true;
        apiRequest("localsend.devices", {}, { kind: "devices" });
    }

    function sendFile(device) {
        if (sendingFile || selectedFile.length === 0 || !device) return;
        const target = String(device.alias || device.fingerprint || "");
        if (target.length === 0) return;
        sendTarget = target;
        sendingFile = true;
        // The receiving device shows a prompt, so this can sit for a long time; say so rather
        // than looking stuck.
        sendStatus = "Waiting for " + target + " to accept " + fileName(selectedFile) + "...";
        apiRequest("localsend.send", { device: target, files: [selectedFile] }, { kind: "send", file: selectedFile, target: target });
    }

    function applyDevices(data) {
        devices = Array.isArray(data) ? data : [];
        scanning = false;
        scanned = true;
    }

    function applySend(ok, error, meta) {
        sendingFile = false;
        const file = meta.file || selectedFile;
        const target = meta.target || sendTarget;
        if (ok) {
            sendStatus = "Sent " + fileName(file) + " to " + target;
            selectedFile = "";
        } else {
            sendStatus = error || ("Failed to send " + fileName(file) + " to " + target);
        }
    }

    function apiRequest(method, params, meta) {
        // Only the newest discovery matters; a queued one that has not gone out yet is dropped.
        if (method === "localsend.devices") {
        // Never drop the request that has already gone out: its response is still coming, and
        // the reader identifies a response by this queue's first entry. Removing an in-flight
        // request here makes every later response line up against the wrong one, so a status
        // reply gets applied as something else and `connected` is never set.
            const inFlight = _requestInFlight && _requestQueue.length > 0 ? [_requestQueue[0]] : [];
            const queued = _requestQueue.slice(inFlight.length).filter(request => request.method !== method);
            _requestQueue = inFlight.concat(queued);
        }
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
        // Discovery listens for answers for over a second; a send waits on a person.
        requestTimeout.interval = request.meta.kind === "send" ? 200000 : 8000;
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
            root.scanning = false;
            if (request && request.meta.kind === "send") {
                root.applySend(false, "The device never answered", request.meta);
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
                    root.scanning = false;
                    return;
                }
                root.backendError = "";
                root.sendNextRequest();
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
                        console.log("localsend epochoxide parse error:", e, line);
                        root.finishRequest();
                        return;
                    }
                    const ok = response.ok !== false;
                    const data = response.data || {};
                    const error = response.error || data.message || "";
                    root.backendError = ok ? "" : error;
                    if (request.meta.kind === "devices") {
                        if (ok) root.applyDevices(data);
                        else root.scanning = false;
                    } else if (request.meta.kind === "send") {
                        root.applySend(ok, error, request.meta);
                    }
                    root.finishRequest();
                }
            }
        }
    }
}
