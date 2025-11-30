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
                  if(S.NetworkMonitor.ethernetConnected) return "󰌗"
                  return "󰌙"
                }
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                color: T.Config.fg
            }
        }
        Column {
            height:parent.height
            width: parent.width
            spacing: 10

            Text {
                text: S.NetworkMonitor.ethernetConnected ? S.NetworkMonitor.ethernetDeviceName : "Disconnected"
                color: "white"
                font.pixelSize: 16
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: S.NetworkMonitor.ethernetConnected ? S.NetworkMonitor.ethernetConnectedIP : "Disconnected"
                color: T.Config.fg
                font.pixelSize: 14;
                            anchors.horizontalCenter: parent.horizontalCenter
            }
        }

}
