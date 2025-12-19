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

Item {
    required property bool connectedStatus
    required property string networkIconText
    required property string connectedName
    required property string connectedIp

    Layout.fillWidth: true
    Layout.preferredHeight: root.implicitHeight
    RowLayout {
        id: root
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20
        Process {
            id: wlcopy
        }

        Rectangle {
            id: iconTile
            width: 40
            height: 40
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            radius: 20
            color: T.Config.surface
            border.color: connectedStatus ? T.Config.accent : T.Config.surfaceContainerHighest
            border.width: 2
            antialiasing: true

            Text {
                text: networkIconText
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                color: T.Config.surfaceText
            }
        }

        ColumnLayout {
            spacing: 10

            Rectangle {
                id: nameWrapper
                width: name.implicitWidth
                height: name.implicitHeight
                color: "transparent"

                Text {
                    id: name
                    text: connectedStatus ? connectedName : "Disconnected"
                    color: T.Config.surfaceText
                    font.pixelSize: 16
                }

                MouseArea {
                    id: mouseAreaName
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: mouse => {
                        wlcopy.command = ["wl-copy", connectedName];
                        wlcopy.running = true;
                    }
                }
            }

            Rectangle {
                id: ipWrapper
                width: ip.implicitWidth
                height: ip.implicitHeight
                color: "transparent"

                Text {
                    id: ip
                    text: connectedStatus ? connectedIp : "Disconnected"
                    color: T.Config.surfaceText
                    font.pixelSize: 14
                }

                MouseArea {
                    id: mouseAreaIp
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: mouse => {
                        wlcopy.command = ["wl-copy", connectedIp];
                        wlcopy.running = true;
                    }
                }
            }
        }
    }
}
