import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

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
            border.color: S.Tailscale.connected ? T.Config.green : T.Config.red
            border.width: 2 
            antialiasing: true

              Text {
                text:  "󰒄"
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                color: T.Config.fg
            }
        }

        Column {
            height:parent.height
            anchors.left: iconTile.right
            width: parent.width
            spacing: 10

              Rectangle {
                id: dnsWrapper
                width: dns.implicitWidth
                height: dns.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Text {
                    id: dns
                    text: S.Tailscale.connected ? S.Tailscale.magicDNSSuffix : "Disconnected"
                    color: T.Config.fg
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    id: mouseAreaDns
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked:(mouse)=> {
                        wlcopy.command = ["wl-copy", S.Tailscale.magicDNSSuffix]
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
                    text: S.Network.tailscaleConnected ? S.Network.tailscaleConnectedIP : "Disconnected"
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
                        wlcopy.command = ["wl-copy", S.Network.tailscaleConnectedIP]
                        wlcopy.running = true
                    }
                }
            }
        }
}
