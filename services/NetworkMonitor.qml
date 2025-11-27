// NetworkMonitor.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: net
    //
    // === PUBLIC PROPERTIES ===
    //
    property bool wifiEnabled: true      // no direct nmcli output — assume true
    property bool scanning: false      // no direct nmcli output — assume true
    property bool connecting: false
    property string connectingTo: ""
    property bool connected: false
    property string ssid: ""
    property int strength: 0
    property var accessPoints: []        // array of { ssid, strength, active }
    // model of saved wifi connections (those with a profile in NM)
    property alias savedAccessPoints: savedWifiModel
    ListModel {
        id: savedWifiModel
    }



    Timer {
        id: refreshTimer
        interval: 5000    // 4 seconds
        running: true
        repeat: true
        onTriggered: refreshStatus()
    }

    Component.onCompleted: net.refresh()

    Process {
        id: wifiStatusCmd
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi" ]

        stdout: StdioCollector {
            onStreamFinished: {
                net._parseWifiStatus(text)
            }
        }
    }

    Process {
        id: scanCmd
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi" ]
        stdout: StdioCollector {
            onStreamFinished: {
                net._parseScan(text)
                scanning = false
            }
        }
    }

    Process {
        id: connectCmd
        command: "nmcli"
        stdout: StdioCollector {
            onStreamFinished: {
                net.refresh()
                connecting = false
                connectingTo = ""
            }
        }
    }

    Process {
        id: deleteCmd
        command: ["nmcli", "connection", "delete"]
        onExited: {
            refreshSaved()
        }

    }

       // grab saved connections once at startup
    // you can re-run this on a timer if you want it to refresh
    Process {
        id: savedNetworks
        // running: true
        // -t: terse, -f: fields we care about
        // we only keep entries where TYPE == wifi
        command: [ "sh", "-c", "nmcli -t -f NAME,TYPE connection show" ]

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
                        savedWifiModel.append({ ssid: name });
                }
            }
        }
    }
    

    function refreshAvailable(callback) {
        scanning = true
        scanCmd.running = true
    }

    function refreshSaved() {
        savedWifiModel.clear()  
        savedNetworks.running = true
    }

    function refreshStatus() {
        wifiStatusCmd.running = true
    }

    function refresh() {
        savedNetworks.running = true
        wifiStatusCmd.running = true
    }

    function connectTo(ssidName) {
        connecting = true
        connectingTo = ssidName
        connectCmd.command = ["nmcli", "device", "wifi", "connect", ssidName]
        connectCmd.running = true
    }

     function deleteNetwork(ssidName) {
        deleteCmd.command = ["nmcli", "connection", "delete", ssidName]
        deleteCmd.running = true
    }



    function _parseWifiStatus(text) {
        let lines = text.trim().split("\n")
        if (lines.length === 0) {
            connected = false
            ssid = ""
            strength = 0
            return
        }

        // Find the active entry (ACTIVE=yes)
        let activeLine = lines.find(l => l.startsWith("yes:"))
        if (!activeLine) {
            connected = false
            ssid = ""
            strength = 0
            return
        }

        let p = activeLine.split(":")
        connected = (p[0] === "yes")
        ssid = p[1] ?? ""
        strength = parseInt(p[2] ?? "0") || 0
    }

    function _parseScan(text) {
        let lines = text.trim().split("\n")
        let aps = []

        for (let line of lines) {
            let p = line.split(":")
            aps.push({
                active: p[0] === "yes",
                ssid: p[1],
                strength: parseInt(p[2] ?? "0") || 0
            })
        }

        // Dedupe by SSID
        let map = {}
        for (let ap of aps) {
            if (!ap.ssid) continue
            let key = ap.ssid
            if (!map[key] || ap.active || ap.strength > map[key].strength)
                map[key] = ap
        }

        accessPoints = Object.values(map).sort((a, b) => b.strength - a.strength)
    }

}
