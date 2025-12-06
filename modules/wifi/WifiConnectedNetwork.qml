import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import qs.theme as T
import qs.services as S

Rectangle {
    id: root
    width: 260
    height: 40
    radius: 6
    color: "transparent"

    Process {
        id: wlcopy
    }


    Rectangle {
        id: iconTile
        width: 40
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        radius: 20
        color: T.Config.bg0 
        border.color: S.Network.wifiConnected ? T.Config.green : T.Config.red
        border.width: 2 
        antialiasing: true

          Text {
            text:  {
                const s = S.Network.strength

                if (!S.Network.wifiConnected) return "󰤭"
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

    Column {
        height:parent.height
        width: parent.width
        anchors.left: iconTile.right
        spacing: 10

          Rectangle {
            id: ssidWrapper
            width: ssid.implicitWidth
            height: ssid.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Text {
                id: ssid
                text: S.Network.wifiConnected ? S.Network.ssid : "Disconnected"
                color: T.Config.fg
                font.pixelSize: 16
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                id: mouseAreaSSID
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked:(mouse)=> {
                    wlcopy.command = ["wl-copy", S.Network.ssid]
                    wlcopy.running = true
                }
            }

        }

        Rectangle {
            id: ipWrapper
            width: ip.implicitWidth
            height: ip.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Text {
                id: ip
                text: S.Network.wifiConnected ? S.Network.wifiConnectedIP : "Disconnected"
                color: T.Config.fg
                font.pixelSize: 14;
                anchors.horizontalCenter: parent.horizontalCenter
            }


            MouseArea {
                id: mouseAreaIp
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked:(mouse)=> {
                    wlcopy.command = ["wl-copy", S.Network.ethernetConnectedIP]
                    wlcopy.running = true
                }
            }
        }
    }
}
