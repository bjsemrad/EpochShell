pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: net

    property var networkConnections: {} // map of device,  { name, type, strength, ipv4 }

    property bool wifiEnabled: true
    property bool wifiScanning: false
    property bool wifiConnecting: false
    property string wifiConnectingTo: ""
    property string ssid: ""
    property int strength: 0

    property var accessPoints: []        // array of { ssid, strength, active }
    property alias savedAccessPoints: savedWifiModel
    ListModel {
        id: savedWifiModel
    }

    property bool wifiConnected: false
    property bool wifiDevice: false
    property string wifiConnectedIP: ""
    property bool ethernetConnected: false
    property bool ethernetDevice: false
    property string ethernetDeviceName: ""
    property string ethernetConnectedIP: ""
    property bool tailscaleConnected: false
    property string tailscaleConnectedIP: ""

    readonly property string currentNetworkIcon: {
        if (wifiDevice && !ethernetConnected) {
            return currentWifiIcon;
        } else if (ethernetDevice && !wifiConnected) {
            return currentEthernetIcon;
        }
        return "󰛵";
    }
    readonly property string currentEthernetIcon: {
        if (ethernetConnected) {
            return "󰌗";
        }
        return "󰌙";
    }

    readonly property string currentWifiIcon: {
        const s = strength;
        if (!wifiConnected)
            return "󰤭";
        if (s >= 75)
            return "󰤨";
        if (s >= 50)
            return "󰤢";
        if (s >= 25)
            return "󰤟";
        return "󰤟";
    }

    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    Component.onCompleted: net.refresh()

    Process {
        id: activeConnCmd
        command: ["nmcli", "-t", "-f", "ACTIVE,NAME,DEVICE,TYPE", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                net._parseActiveConnections(text);
            }
        }
    }

    function updateProperties() {
        wifiConnected = Object.values(networkConnections).some(c => c.active && c.type === "wifi");
        let wifi = Object.entries(networkConnections).find(([device, conn]) => conn.active && conn.type === "wifi");
        if (wifi) {
            wifiConnectedIP = wifi[1].ipv4;
        }
        ethernetConnected = Object.values(networkConnections).some(c => c.active && c.type === "ethernet");
        let eth = Object.entries(networkConnections).find(([device, conn]) => conn.active && conn.type === "ethernet");
        if (eth) {
            ethernetDeviceName = eth[0];
            ethernetConnectedIP = eth[1].ipv4;
        }
        tailscaleConnected = Object.values(networkConnections).some(c => c.active && c.type === "vpn" && c.name.indexOf("tailscale") >= 0);
        let tail = Object.entries(networkConnections).find(([device, conn]) => conn.active && conn.type === "vpn" && conn.name.indexOf("tailscale") >= 0);
        if (tail) {
            tailscaleConnectedIP = tail[1].ipv4;
        }
    }

    function _parseActiveConnections(text) {
        if (!networkConnections)
            networkConnections = {};

        wifiDevice = false;
        ethernetDevice = false;
        let lines = text.trim().split("\n");
        for (let line of lines) {
            let parts = line.split(":");
            let active = parts[0];
            let name = parts[1];
            let device = parts[2];
            let parsedType = parts[3];
            let type = "none";

            if (parsedType.indexOf("wireless") >= 0) {
                type = "wifi";
                wifiDevice = true;
            } else if (parsedType.indexOf("ethernet") >= 0) {
                type = "ethernet";
                ethernetDevice = true;
            } else if (parsedType.indexOf("tun") >= 0) {
                type = "vpn";
            }

            if (type !== "none") {
                if (!networkConnections[device]) {
                    networkConnections[device] = {};
                }
                Object.assign(networkConnections[device], {
                    active: active === "yes" ? true : false,
                    name: name,
                    type: type,
                    ipv4: ""
                });
            }
        }
        ipCmd.running = true;
    }

    Process {
        id: ipCmd
        command: ["sh", "-c", "for d in $(nmcli -t -f DEVICE device); do " + "ip=$(nmcli -t -f IP4.ADDRESS device show \"$d\" | head -n1 | cut -d: -f2 | cut -d/ -f1); " + "echo \"$d:$ip\"; " + "done"]

        stdout: StdioCollector {
            onStreamFinished: {
                _parseActiveIPAddresses(text);
                updateProperties();
            }
        }
    }

    function _parseActiveIPAddresses(text) {
        let lines = text.trim().split("\n");
        for (let line of lines) {
            if (line.trim() === "") {
                continue;
            }
            let parts = line.split(":");
            let device = parts[0];
            let ip = parts[1] || "";
            if (networkConnections[device]) {
                networkConnections[device].ipv4 = ip;
            }
        }
    }

    Process {
        id: wifiStatusCmd
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                net._parseWifiStatus(text);
            }
        }
    }

    Process {
        id: scanCmd
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                net._parseScan(text);
                wifiScanning = false;
            }
        }
    }

    Process {
        id: connectCmd
        command: "nmcli"
        stdout: StdioCollector {
            onStreamFinished: {
                net.refresh();
                wifiConnecting = false;
                wifiConnectingTo = "";
            }
        }
    }

    Process {
        id: deleteCmd
        command: ["nmcli", "connection", "delete"]
        onExited: {
            refreshSaved();
        }
    }

    // grab saved connections once at startup
    // you can re-run this on a timer if you want it to refresh
    Process {
        id: savedNetworks
        // running: true
        // -t: terse, -f: fields we care about
        // we only keep entries where TYPE == wifi
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE connection show"]

        stdout: SplitParser {
            onRead: line => {
                if (!line.length)
                    return;

                const parts = line.split(":");
                if (parts.length < 2)
                    return;

                const name = parts[0];
                const type = parts[1];
                if (type.indexOf("wireless") !== -1) {
                    for (let i = 0; i < savedWifiModel.count; ++i) {
                        if (savedWifiModel.get(i).ssid === name)
                            return;
                    }
                    savedWifiModel.append({
                        ssid: name
                    });
                }
            }
        }
    }

    function refreshAvailable(callback) {
        wifiScanning = true;
        scanCmd.running = true;
    }

    function refreshSaved() {
        savedWifiModel.clear();
        savedNetworks.running = true;
    }

    function refreshStatus() {
        wifiStatusCmd.running = true;
    }

    function refresh() {
        activeConnCmd.running = true;
        savedNetworks.running = true;
        wifiStatusCmd.running = true;
    }

    function connectTo(ssidName) {
        wifiConnecting = true;
        wifiConnectingTo = ssidName;
        connectCmd.command = ["nmcli", "device", "wifi", "connect", ssidName];
        connectCmd.running = true;
    }

    function deleteNetwork(ssidName) {
        deleteCmd.command = ["nmcli", "connection", "delete", ssidName];
        deleteCmd.running = true;
    }

    function _parseWifiStatus(text) {
        let lines = text.trim().split("\n");
        if (lines.length === 0) {
            // wifiConnected = false
            ssid = "";
            strength = 0;
            return;
        }

        // Find the active entry (ACTIVE=yes)
        let activeLine = lines.find(l => l.startsWith("yes:"));
        if (!activeLine) {
            // wifiConnected = false
            ssid = "";
            strength = 0;
            return;
        }

        let p = activeLine.split(":");
        // wifiConnected = (p[0] === "yes")
        ssid = p[1] ?? "";
        strength = parseInt(p[2] ?? "0") || 0;
    }

    function _parseScan(text) {
        let lines = text.trim().split("\n");
        let aps = [];

        for (let line of lines) {
            let p = line.split(":");
            aps.push({
                active: p[0] === "yes",
                ssid: p[1],
                strength: parseInt(p[2] ?? "0") || 0
            });
        }

        // Dedupe by SSID
        let map = {};
        for (let ap of aps) {
            if (!ap.ssid)
                continue;
            let key = ap.ssid;
            if (!map[key] || ap.active || ap.strength > map[key].strength)
                map[key] = ap;
        }

        accessPoints = Object.values(map).sort((a, b) => b.strength - a.strength);
    }

    Process {
        id: editorProcess
        command: ["nm-connection-editor"]
    }

    function editNetworks() {
        editorProcess.startDetached();
    }

    Process {
        id: disableWifi
    }

    function disableWifi(on) {
        wifiEnabled = on;
        if (!wifiEnabled) {
            networkConnections = {};
        }
        disableWifi.command = ["nmcli", "radio", "wifi", wifiEnabled ? "on" : "off"];
        disableWifi.running = true;
        refresh();
    }
}
