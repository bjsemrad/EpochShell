pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme as T

Singleton {
    id: tail

    property bool connected: false
    property string magicDNSSuffix: ""

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

                        arr.push({
                            hostName: p.HostName || "",
                            dnsName: p.DNSName.slice(0, -1) || "",
                            connected: !!p.Online,
                            ip: (p.TailscaleIPs && p.TailscaleIPs.length > 0) ? p.TailscaleIPs[0] : ""
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
