// components/Net.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import '../theme' as T
import '../services' as S
Rectangle {
    id: root
    // implicitWidth: 24
    // implicitHeight: 24
    color: "transparent"
    //border.color: T.Config.blue //isActive ? _tileRingActive : "transparent"
    // border.width: 2 
    // radius: 20
    implicitWidth: inner.implicitWidth + 10
    implicitHeight: inner.implicitHeight + 10

    // wired to popup from the bar
    property var popup
    // exported so popup can highlight the active SSID
    // property string activeSsid: ""
    // property bool wiredConnected: false
    // property bool wifiConnected: false
    // property int wifiSignal: 0           // 0–100
    // property string iconName: "network-offline-symbolic"

    // // --- update cadence
    // Timer {
    //     id: poll
    //     interval: 5000
    //     repeat: true
    //     running: true
    //     onTriggered: updateIcon()
    // }

    // onVisibleChanged: {
    //     if (visible){
    //         // updateIcon()
    //     }
    // }
    //
    // function wifiBars(sig) {
    //     if (sig >= 75) return "network-wireless-signal-excellent-symbolic"
    //     if (sig >= 50) return "network-wireless-signal-high-symbolic"
    //     if (sig >= 25) return "network-wireless-signal-medium-symbolic"
    //     if (sig >   0) return "network-wireless-signal-low-symbolic"
    //     return "network-wireless-low-symbolic"
    // }
    //
    // function updateIcon() {
    //     // if (root.wiredConnected) {
    //         // iconName = "network-wired-symbolic"
    //     //} else
    //     if (S.NetworkMonitor.connected) {
    //         iconName = wifiBars(S.NetworkMonitor.strength)
    //     } else {
    //         iconName = "network-offline-symbolic"
    //     }
    // }
    //
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
    //

    Row {
        id: inner
        anchors.centerIn: parent
        anchors.rightMargin: 10
        spacing: 5 
        IconImage {
            implicitSize: 18
            source: {
                const s = S.NetworkMonitor.strength

                if (!S.NetworkMonitor.connected) return Quickshell.iconPath("network-offline-symbolic")
                if (s >= 75) return Quickshell.iconPath("network-wireless-signal-excellent-symbolic")
                if (s >= 50) return Quickshell.iconPath("network-wireless-signal-good-symbolic")
                if (s >= 25) return Quickshell.iconPath("network-wireless-signal-ok-symbolic")
                return Quickshell.iconPath("network-wireless-signal-weak-symbolic")
            }
         }
    }
}
