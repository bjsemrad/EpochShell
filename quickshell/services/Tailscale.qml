pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme as T

Singleton {
    id: tail

    property bool connected: false
    property string magicDNSSuffix: ""
    property string selectedFile: ""
    property bool sendingFile: false
    property string sendStatus: ""
    property string sendTarget: ""

    // each row: { hostName, dnsName, connected, ip }
    property var peers: []

    readonly property string currentTailscaleIcon: connected ? "󰒄" : "󰅛"

    Process {
        id: gui
        command: ["trayscale"]
    }

    function trayscale() {
        gui.startDetached();
    }

    Process {
        id: tailscaleUp
        command: ["tailscale", "up"]
    }

    Process {
        id: tailscaleDown
        command: ["tailscale", "down"]
    }

    function toggle(connect) {
        if (connect) {
            tailscaleUp.running = true;
        } else {
            tailscaleDown.running = true;
        }
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
        taildropProc.command = ["bash", "-c", "if tailscale file cp \"$1\" \"$2:\" >/dev/null; then printf ok; else printf fail; fi", "--", selectedFile, target];
        taildropProc.running = true;
    }

    Process {
        id: taildropProc
        stdout: StdioCollector {
            id: taildropOut
            waitForEnd: true
            onStreamFinished: {
                const ok = taildropOut.text.trim() === "ok";
                sendingFile = false;
                sendStatus = ok ? ("Sent " + fileName(selectedFile) + " to " + sendTarget) : ("Failed to send " + fileName(selectedFile) + " to " + sendTarget);
                if (ok) selectedFile = "";
            }
        }
        stderr: StdioCollector {
            id: taildropErr
            waitForEnd: true
        }
    }

    Timer {
        id: statusProcTim
        interval: 30000
        running: true
        repeat: true
        onTriggered: refresh()
    }
    Component.onCompleted: tail.refresh()

    function refresh() {
        statusProc.running = true;
    }

    Process {
        id: statusProc
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            id: out
            onStreamFinished: {
                try {
                    let arr = [];
                    const jsonText = out.text;
                    const obj = JSON.parse(jsonText);

                    magicDNSSuffix = obj.MagicDNSSuffix || "";
                    connected = obj.BackendState === "Running";

                    const peers = obj.Peer || {};
                    for (var key in peers) {
                        if (!peers.hasOwnProperty(key))
                            continue;
                        const p = peers[key];

                        const dnsName = p.DNSName ? p.DNSName.slice(0, -1) : "";
                        const ip = (p.TailscaleIPs && p.TailscaleIPs.length > 0) ? p.TailscaleIPs[0] : "";
                        arr.push({
                            hostName: p.HostName || "",
                            dnsName: dnsName,
                            connected: !!p.Online,
                            ip: ip,
                            taildropTarget: p.HostName || dnsName || ip
                        });
                    }

                    tail.peers = arr;
                    measureWidths();
                } catch (e) {
                    console.log("tailscale status parse error:", e);
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
