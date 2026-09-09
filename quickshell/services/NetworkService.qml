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

    readonly property string currentNetworkIcon: {
        if (ethernetConnected) {
            return currentEthernetIcon;
        } else if (wifiConnected) {
            return currentWifiIcon;
        } else if (ethernetDevice) {
            return currentEthernetIcon;
        } else if (wifiDevice) {
            return currentWifiIcon;
        }
        return "󰛵";
    }
    readonly property string currentEthernetIcon: {
        if (ethernetConnected) {
            return "󰌘";
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

    Process {
        id: deviceCmd
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE", "device"]

        stdout: StdioCollector {
            onStreamFinished: {
                net._parseDevices(text);
            }
        }
    }

    function updateProperties() {
        wifiConnected = Object.values(networkConnections).some(c => c.active && c.type === "wifi");
        let wifi = Object.entries(networkConnections).find(([device, conn]) => conn.active && conn.type === "wifi");
        if (wifi) {
            wifiConnectedIP = wifi[1].ipv4;
        } else {
            wifiConnectedIP = "";
        }
        ethernetConnected = Object.values(networkConnections).some(c => c.active && c.type === "ethernet");
        let eth = Object.entries(networkConnections).find(([device, conn]) => conn.active && conn.type === "ethernet");
        if (eth) {
            ethernetDeviceName = eth[0];
            ethernetConnectedIP = eth[1].ipv4;
        } else {
            ethernetDeviceName = "";
            ethernetConnectedIP = "";
        }
    }

    function _parseActiveConnections(text) {
        let connections = {};
        let lines = text.trim().split("\n");
        for (let line of lines) {
            if (line.trim() === "") {
                continue;
            }
            let parts = line.split(":");
            if (parts.length < 4 || parts[2] === "") {
                continue;
            }
            let devActive = parts[0];
            let name = parts[1];
            let device = parts[2];
            let parsedType = parts[3];
            let type = "none";
            if (parsedType.indexOf("wireless") >= 0) {
                type = "wifi";
            } else if (parsedType.indexOf("ethernet") >= 0) {
                type = "ethernet";
            } else if (parsedType.indexOf("tun") >= 0) {
                type = "vpn";
            }

            if (type !== "none") {
                connections[device] = {
                    active: devActive === "yes" ? true : false,
                    name: name,
                    type: type,
                    ipv4: ""
                };
            }
        }
        networkConnections = connections;
        ipCmd.running = true;
    }

    function _parseDevices(text) {
        wifiDevice = false;
        ethernetDevice = false;

        let lines = text.trim().split("\n");
        for (let line of lines) {
            if (line.trim() === "") {
                continue;
            }

            let parts = line.split(":");
            if (parts.length < 2) {
                continue;
            }

            let type = parts[1];
            if (type === "wifi" || type.indexOf("wireless") >= 0) {
                wifiDevice = true;
            } else if (type.indexOf("ethernet") >= 0) {
                ethernetDevice = true;
            }
        }
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

    Process {
        id: savedNetworks
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
        deviceCmd.running = true;
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
            //  = false
            ssid = "";
            strength = 0;
            return;
        }

        let activeLine = lines.find(l => l.startsWith("yes:"));
        if (!activeLine) {
            ssid = "";
            strength = 0;
            return;
        }

        let p = activeLine.split(":");
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
