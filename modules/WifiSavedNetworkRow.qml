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

    property string ssid: ""

    Row {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Rectangle {
            border.width: T.Config.selectedBorderWidth
            radius: 6
            border.color: mouseArea.containsMouse ? T.Config.fg : "transparent"
            implicitWidth: parent.width
            implicitHeight: parent.height
            color: "transparent"
             Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width


                    Text {
                        text: "󰤨"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        color: T.Config.fg
                    }

                    Text {
                        text: root.ssid
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        font.pixelSize: 13
                    }

                    Spinner {
                        id: wifiSpinner
                        running: S.NetworkMonitor.wifiConnecting && S.NetworkMonitor.wifiConnectingTo === root.ssid
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
    }
}
