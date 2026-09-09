pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme as T

Singleton {
    id: tail

    property bool connected: false
    property bool available: false
    property string magicDNSSuffix: ""
    property string connectedIP: ""
    property string selectedFile: ""
    property bool sendingFile: false
    property string sendStatus: ""
    property string sendTarget: ""
    property var incomingFiles: []
    readonly property bool hasIncomingFiles: incomingFiles.length > 0
    property bool receivingFiles: false
    property string receiveStatus: ""
    property string receiveDirectory: ""
    property int _lastIncomingCount: 0
    property string backendError: ""
    property var _requestQueue: []
    property bool _requestInFlight: false

    // each row: { hostName, dnsName, connected, ip }
    property var peers: []

    readonly property string currentTailscaleIcon: connected ? "󰒄" : "󰅛"
    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    Process {
        id: gui
        command: ["trayscale"]
    }

    function trayscale() {
        gui.startDetached();
    }

    function toggle(connect) {
        apiRequest(connect ? "tailscale.up" : "tailscale.down", {}, { kind: "toggle", connect: connect });
    }

    function fileName(path) {
        const value = String(path || "");
        const idx = value.lastIndexOf("/");
        return idx >= 0 ? value.slice(idx + 1) : value;
    }

    function clearSelectedFile() {
        selectedFile = "";
        sendStatus = "";
        sendTarget = "";
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
        if (path.length > 0) {
            selectedFile = path;
            sendStatus = "Pick a peer to send " + fileName(path);
        }
    }

    function targetForPeer(peer) {
        if (!peer) return "";
        return peer.hostName || peer.dnsName || peer.ip || "";
    }

    function sendFile(peer) {
        if (sendingFile || selectedFile.length === 0) return;
        const target = targetForPeer(peer);
        if (target.length === 0) return;
        sendTarget = target;
        sendStatus = "Sending " + fileName(selectedFile) + " to " + target + "...";
        sendingFile = true;
        apiRequest("tailscale.send", { peer: target, files: [selectedFile] }, { kind: "send", file: selectedFile, target: target });
    }

    Timer {
        id: statusProcTim
        interval: 30000
        running: true
        repeat: true
        onTriggered: refresh()
    }
    Timer {
        id: incomingProcTim
        interval: 10000
        running: true
        repeat: true
        onTriggered: refreshIncoming()
    }
    Component.onCompleted: tail.refresh()

    function refresh() {
        apiRequest("tailscale.status", {}, { kind: "status" });
        apiRequest("tailscale.machines", {}, { kind: "machines" });
        refreshIncoming();
    }

    function refreshIncoming() {
        apiRequest("tailscale.pendingFiles", {}, { kind: "incoming" });
    }

    function receiveFiles(directory) {
        const target = pathFromUrl(directory);
        if (receivingFiles || target.length === 0) return;
        receiveDirectory = target;
        receivingFiles = true;
        receiveStatus = "Receiving Taildrop files...";
        apiRequest("tailscale.receive", { directory: target }, { kind: "receive", directory: target });
    }

    function apiRequest(method, params, meta) {
        if (method === "tailscale.status" || method === "tailscale.machines" || method === "tailscale.pendingFiles") {
            _requestQueue = _requestQueue.filter(request => request.method !== method);
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
        requestTimeout.interval = (request.meta.kind === "send" || request.meta.kind === "receive") ? 120000 : 5000;
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

    function applyStatus(data) {
        available = true;
        magicDNSSuffix = data.magic_dns_suffix || "";
        connected = !!data.running;
        const selfMachine = data.self_machine || {};
        const ips = Array.isArray(selfMachine.ips) ? selfMachine.ips : [];
        connectedIP = ips.length > 0 ? ips[0] : "";
    }

    function applyMachines(data) {
        let arr = [];
        const machines = Array.isArray(data) ? data : [];
        for (const machine of machines) {
            if (machine.is_self) continue;
            const ips = Array.isArray(machine.ips) ? machine.ips : [];
            const name = machine.name || "";
            const dnsName = machine.dns_name || "";
            arr.push({
                hostName: name,
                dnsName: dnsName,
                connected: !!machine.online,
                ip: ips.length > 0 ? ips[0] : "",
                taildropTarget: name || dnsName
            });
        }
        tail.peers = arr;
        measureWidths();
    }

    function formatBytes(size) {
        let value = Number(size || 0);
        const units = ["B", "KiB", "MiB", "GiB"];
        let unit = 0;
        while (value >= 1024 && unit < units.length - 1) {
            value = value / 1024;
            unit++;
        }
        return unit === 0 ? (Math.round(value) + " " + units[unit]) : (value.toFixed(1) + " " + units[unit]);
    }

    function applySend(ok, error, meta) {
        sendingFile = false;
        const file = meta.file || selectedFile;
        const target = meta.target || sendTarget;
        sendStatus = ok ? ("Sent " + fileName(file) + " to " + target) : (error || ("Failed to send " + fileName(file) + " to " + target));
        if (ok) selectedFile = "";
    }

    function applyIncoming(data) {
        const files = Array.isArray(data) ? data : [];
        incomingFiles = files;
        if (files.length > 0 && files.length !== _lastIncomingCount) {
            receiveStatus = files.length === 1 ? ("1 file waiting to receive") : (files.length + " files waiting to receive");
        }
        _lastIncomingCount = files.length;
    }

    function applyReceive(ok, error, data, meta) {
        receivingFiles = false;
        if (!ok) {
            receiveStatus = error || "Failed to receive Taildrop files";
            return;
        }
        const moved = data.moved || 0;
        const total = data.total || moved;
        if (moved === 0) {
            receiveStatus = "No Taildrop files waiting";
        } else if (moved === total) {
            receiveStatus = moved === 1 ? ("Received 1 file into " + meta.directory) : ("Received " + moved + " files into " + meta.directory);
        } else {
            receiveStatus = "Received " + moved + " of " + total + " files into " + meta.directory;
        }
        refreshIncoming();
    }

    function applyToggle(ok, error, meta) {
        if (!ok) {
            backendError = error || "Failed to change Tailscale state";
            return;
        }
        connected = !!meta.connect;
        refresh();
    }

    Timer {
        id: requestTimeout
        interval: 5000
        repeat: false
        onTriggered: {
            const request = _requestQueue.length > 0 ? _requestQueue[0] : null;
            if (request && request.meta.kind === "send") applySend(false, "EpochOxide timed out", request.meta);
            if (request && request.meta.kind === "receive") applyReceive(false, "EpochOxide timed out", {}, request.meta);
            _requestQueue = [];
            _requestInFlight = false;
            backendError = "EpochOxide is not responding";
            rebuildSocket();
        }
    }

    Timer {
        id: retryTimer
        interval: 2000
        repeat: true
        running: socketLoader.item === null || !socketLoader.item.connected
        onTriggered: rebuildSocket()
    }

    Loader {
        id: socketLoader
        active: true

        sourceComponent: Socket {
            id: epochoxideSocket
            path: tail.socketPath
            connected: true

            onConnectionStateChanged: {
                if (!epochoxideSocket.connected) {
                    tail._requestInFlight = false;
                    return;
                }
                tail.backendError = "";
                tail.sendNextRequest();
            }

            onError: function (error) {
                tail.backendError = tail.socketErrorText(error);
            }

            parser: SplitParser {
                onRead: function (line) {
                    const request = tail._requestQueue.length > 0 ? tail._requestQueue[0] : null;
                    if (!request) return;
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("tailscale epochoxide parse error:", e, line);
                        tail.finishRequest();
                        return;
                    }
                    const ok = response.ok !== false;
                    const data = response.data || {};
                    const error = response.error || (data.message || "");
                    tail.backendError = ok ? "" : error;
                    if (request.meta.kind === "status" && !ok) tail.available = false;
                    if (request.meta.kind === "status" && ok) tail.applyStatus(data);
                    else if (request.meta.kind === "machines" && ok) tail.applyMachines(data);
                    else if (request.meta.kind === "incoming" && ok) tail.applyIncoming(data);
                    else if (request.meta.kind === "send") tail.applySend(ok, error, request.meta);
                    else if (request.meta.kind === "receive") tail.applyReceive(ok, error, data, request.meta);
                    else if (request.meta.kind === "toggle") tail.applyToggle(ok, error, request.meta);
                    tail.finishRequest();
                }
            }
        }
    }

    property real colHostWidth: 0
    property real colIpWidth: 0
    property real colDnsWidth: 0

    function measureWidths() {
        var maxH = 0, maxI = 0, maxD = 0;

        for (let i = 0; i < peers.length; i++) {
            const p = peers[i];
            maxH = Math.max(maxH, metrics.widthOf(p.hostName || ""));
            maxI = Math.max(maxI, metrics.widthOf(p.ip || ""));
            maxD = Math.max(maxD, metrics.widthOf(p.dnsName || ""));
        }

        colHostWidth = maxH + 12;
        colIpWidth = maxI + 12;
        colDnsWidth = maxD + 12;
    }

    TextMetrics {
        id: metrics
        font.pixelSize: T.Config.tailscalePeersFontSize

        function widthOf(str) {
            text = str;
            return advanceWidth;
        }
    }
}
