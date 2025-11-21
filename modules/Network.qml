// components/Net.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import '../theme' as T
Rectangle {
    id: root
    // implicitWidth: 24
    // implicitHeight: 24
    color: T.Config.bg2
    //border.color: T.Config.blue //isActive ? _tileRingActive : "transparent"
    border.width: 2 
    radius: 20
    implicitWidth: inner.implicitWidth + 10 * 2
    implicitHeight: inner.implicitHeight + 10 * 2

    // wired to popup from the bar
    property var popup
    // exported so popup can highlight the active SSID
    property string activeSsid: ""
    property bool wiredConnected: false
    property bool wifiConnected: false
    property int wifiSignal: 0           // 0–100
    property string iconName: "network-offline-symbolic"

    // --- update cadence
    Timer {
        id: poll
        interval: 3000
        repeat: true
        running: true
        onTriggered: updateStatus()
    }
    Component.onCompleted: updateStatus()

    function updateStatus() {
        // 1) Device status for wired/wifi connection states
        devStatus.running = true
        // 2) Active connections to get active SSID name
        activeConn.running = true
        // 3) Wi-Fi scan to get signal for active SSID
        wifiScan.running = true
    }

    // nmcli - device status
    Process {
        id: devStatus
        running: false
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let wifiState = "disconnected"
                let ethState = "disconnected"
                for (let l of lines) {
                    const [dev, type, state] = l.split(":")
                    if (type === "wifi") wifiState = state
                    if (type === "ethernet") ethState = state
                }
                root.wifiConnected  = (wifiState === "connected")
                root.wiredConnected = (ethState === "connected")
                updateIcon()
            }
        }
    }

    // nmcli - active connections (NAME is SSID on most systems)
    Process {
        id: activeConn
        running: false
        command: ["nmcli", "-t", "-f", "ACTIVE,NAME,DEVICE,TYPE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.activeSsid = ""
                const lines = text.trim().split("\n")
                for (let l of lines) {
                    const [active, name, dev, type] = l.split(":")
                    if (active === "yes" && (type === "wifi" || type.indexOf("802-11-wireless") !== -1)) {
                        root.activeSsid = name
                        break
                    }
                }
            }
        }
    }

    // nmcli - wifi scan (to get signal level for active SSID)
    Process {
        id: wifiScan
        running: false
        command: ["nmcli", "--rescan", "yes", "-t", "-f", "IN-USE,SIGNAL,SSID", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                let best = 0
                const lines = text.trim().split("\n").filter(s => s.length > 0)
                for (let l of lines) {
                    // IN-USE can be "*" on the active row
                    const parts = l.split(":")
                    // Format can be "*:77:/dev/net" or ":60:SomeSSID"
                    const inuse = parts[0] === "*"    // some distros add '*' here
                    const signal = parseInt(parts[1] || "0")
                    const ssid = parts.slice(2).join(":")  // SSIDs may contain ':'
                    if (inuse || (ssid && ssid === root.activeSsid)) {
                        best = Math.max(best, signal)
                    }
                }
                root.wifiSignal = best
                updateIcon()
            }
        }
    }

    function wifiBars(sig) {
        if (sig >= 75) return "network-wireless-signal-excellent-symbolic"
        if (sig >= 50) return "network-wireless-signal-high-symbolic"
        if (sig >= 25) return "network-wireless-signal-medium-symbolic"
        if (sig >   0) return "network-wireless-signal-low-symbolic"
        return "network-wireless-offline-symbolic"
    }

    function updateIcon() {
        if (root.wiredConnected) {
            iconName = "network-wired-symbolic"
        } else if (root.wifiConnected) {
            iconName = wifiBars(root.wifiSignal)
        } else {
            iconName = "network-offline-symbolic"
        }
    }

    MouseArea {
    anchors.fill: parent
    onClicked: {
        popup.visible = !popup.visible
    }
    }
    // // open on click OR hover (your choice C)
    // MouseArea {
    //     anchors.fill: parent
    //     hoverEnabled: true
    //     onClicked: if (popup) popup.openPopup( root.activeSsid,
    //         root.wiredConnected,
    //         root.mapToGlobal(0, root.height).x,    // under icon
    //         root.mapToGlobal(0, root.height).y,    // under icon
    //         root.width * 12,                       // popup width (tweak)
    //         root.window?.screen)
    //     onEntered: if (popup) popup.openPopup( root.activeSsid,
    //         root.wiredConnected,
    //         root.mapToGlobal(0, root.height).x,    // under icon
    //         root.mapToGlobal(0, root.height).y,    // under icon
    //         root.width * 12,                       // popup width (tweak)
    //         root.window?.screen)
    // }

    Row {
        id: inner
        anchors.centerIn: parent
        anchors.rightMargin: 10
        spacing: 5 
        // Rectangle {
        // anchors.centerIn: parent
        // border.width: 1
       // border.color: '#578778'
    IconImage {
        // anchors.centerIn: parent
        implicitSize: 18
        source: Quickshell.iconPath(root.iconName)
    }
    
    IconImage {
        // anchors.centerIn: parent
        implicitSize: 18
        source: Quickshell.iconPath("blueman-tray")
    }
    }
}
