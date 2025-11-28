import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import "../services" as S
import "../theme" as T
Rectangle {
    id: root
    width: 260
    height: 40
    radius: 6
    color: "transparent"

    Rectangle {
            id: iconTile
            width: 40
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            radius: 20
            color: T.Config.bg0 //isActive ? _tileBgActive : _tileBgInactive
            border.color: T.Config.blue //isActive ? _tileRingActive : "transparent"
            border.width: 2 
            antialiasing: true

              Text {
                text:  {
                    const s = S.NetworkMonitor.strength

                    if (!S.NetworkMonitor.wifiConnected) return "󰤭"
                    if (s >= 75) return "󰤨"
                    if (s >= 50) return "󰤢"
                    if (s >= 25) return "󰤟"
                    return "󰤟"
                }
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                color: T.Config.fg
            }
        }

        Text {
            text: S.NetworkMonitor.wifiConnected ? S.NetworkMonitor.ssid : "Disconnected"
            color: "white"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
        }
}
