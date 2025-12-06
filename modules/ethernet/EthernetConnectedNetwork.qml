import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
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
            border.color: S.Network.ethernetConnected ? T.Config.green : T.Config.red
            border.width: 2 
            antialiasing: true

              Text {
                text:  {
                  if(S.Network.ethernetConnected) return "󰌗"
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

            Rectangle {
                id: deviceWrapper
                width: device.implicitWidth
                height: device.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                Text {
                    id: device
                    text: S.Network.ethernetConnected ? S.Network.ethernetDeviceName : "Disconnected"
                    color: T.Config.fg
                    font.pixelSize: 16
                }

                MouseArea {
                    id: mouseAreaDevice
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked:(mouse)=> {
                        wlcopy.command = ["wl-copy", S.Network.ethernetDeviceName]
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
                    text: S.Network.ethernetConnected ? S.Network.ethernetConnectedIP : "Disconnected"
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
