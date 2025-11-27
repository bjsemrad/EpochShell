import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import "../theme" as T
import "../services" as S
import "../commonwidgets"

Rectangle {
    id: root
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    radius: 6
    height: 30
    color: "transparent"
    // border.width: 1
    // border.color: mouseArea.containsMouse ? T.Config.blue : "transparent"

    // network properties
    property string ssid: ""

    //  // process to connect to this network
    // Process {
    //     id: connectProcess
    //     command: ["nmcli", "connection", "up", root.ssid]
    // }
    //
    Row {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Rectangle {
            border.width: 1
            radius: 6
            border.color: mouseArea.containsMouse ? T.Config.blue : "transparent"
            implicitWidth: parent.width*.9
            implicitHeight: parent.height
            color: "transparent"
             Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width


                    IconImage {
                        source:  Quickshell.iconPath("network-wireless-symbolic")
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                    }

                    Text {
                        text: root.ssid
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 13
                    }

                    Spinner {
                        id: wifiSpinner
                        running: S.NetworkMonitor.connecting && S.NetworkMonitor.connectingTo === root.ssid
                    }
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        S.NetworkMonitor.connectTo(root.ssid)
                    }
                }
        }

        Rectangle {
            implicitHeight: 18
            implicitWidth: 18
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            IconImage {
                source:  Quickshell.iconPath("window-close-symbolic")
                anchors.verticalCenter: parent.verticalCenter
                 width: 18
                height: 18
            }
            MouseArea {
                id: mouseArea2
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    S.NetworkMonitor.deleteNetwork(root.ssid)
                }
           }
        }
    }
    //
    //  MouseArea {
    //     id: mouseArea
    //     anchors.fill: parent
    //     hoverEnabled: true
    //     cursorShape: Qt.PointingHandCursor
    //     onClicked: {
    //         // fire and forget
    //         connectProcess.startDetached()
    //     }
    // }
}
