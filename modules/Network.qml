// components/Net.qml
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import '../theme' as T
import '../services' as S
Rectangle {
    id: root
    color: "transparent"
    implicitWidth: inner.implicitWidth + 10
    implicitHeight: inner.implicitHeight + 10

    property var popup
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popup.visible = !popup.visible
        }
    }

    Row {
        id: inner
        anchors.centerIn: parent
        anchors.rightMargin: 10
        spacing: 5 
         Text {
            text:  {
                const s = S.NetworkMonitor.strength

                if (!S.NetworkMonitor.connected) return "󰤭"
                if (s >= 75) return "󰤨"
                if (s >= 50) return "󰤢"
                if (s >= 25) return ""
                return "󰤟"
            }
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
        }

        // IconImage {
        //     implicitSize: 18
        //     source: {
        //         const s = S.NetworkMonitor.strength
        //
        //         if (!S.NetworkMonitor.connected) return Quickshell.iconPath("network-offline-symbolic")
        //         if (s >= 75) return Quickshell.iconPath("network-wireless-signal-excellent-symbolic")
        //         if (s >= 50) return Quickshell.iconPath("network-wireless-signal-good-symbolic")
        //         if (s >= 25) return Quickshell.iconPath("network-wireless-signal-ok-symbolic")
        //         return Quickshell.iconPath("network-wireless-signal-weak-symbolic")
        //     }
        //  }
    }
}
