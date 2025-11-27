import Quickshell
import Quickshell.Wayland        // for WlrLayershell + WlrLayer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../commonwidgets"
import "../modules"
import "../theme" as T
import "../services" as S

HoverPopupWindow {
    id: networkPopup
    trigger: trigger
    
    function refresh() {
        S.NetworkMonitor.refresh()
    }

    Timer {
        id: refreshTimer
        interval: 5000  
        repeat: true
        running: networkPopup.visible

        onTriggered: {
            refresh()
        }
    }

    onVisibleChanged: {
        if (visible){
            refresh()
        }
    }

    Row {
        id: networkContent
        spacing: 10
        Column {
            width: T.Config.networkPopupWidth
            spacing: 10
            NetworkOnOff {}
            ComponentSplitter{}
            ConnectedNetwork{}
            ComponentSplitter{}
            SavedWifiNetworks{}
            ComponentSplitter{}
            AvailableNetworks{}
            ComponentSpacer{}
        }
    }
    // Column {
    //     spacing: 10
    //     width: parent.width
    //
    //     // HEADER
    //     Label {
    //         text: "Network"
    //         font.bold: true
    //         font.pixelSize: 15
    //         color: "white"
    //     }
    //
    //     // WIFI SUMMARY + SWITCH
    //     Rectangle {
    //         implicitWidth: parent.width
    //         height: 42
    //         radius: 10
    //         color: T.Config.bg0
    //         // color: net.wifi.enabled ? "#222" : "#333"
    //         border.width: 1
    //         border.color: "#333"
    //         RowLayout {
    //             anchors.fill: parent
    //             anchors.margins: 8
    //             spacing: 10
    //
    //             IconImage {
    //                 source:  Quickshell.iconPath(netMon.connected
    //                         ? "network-wireless-signal-excellent-symbolic"
    //                         : "network-offline-symbolic")
    //                 implicitWidth: 18
    //                 implicitHeight: 18
    //             }
    //
    //             Label {
    //                 text: netMon.connected
    //                       ? `${netMon.ssid}`
    //                       : "Wi-Fi Disabled"
    //                 color: "white"
    //                 Layout.fillWidth: true
    //             }
    //         }
    //     }
    // }

}

