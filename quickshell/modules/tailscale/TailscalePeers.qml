import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as S
import qs.theme as T
import qs.commonwidgets

Item {
    id: peersSection
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight
    Layout.bottomMargin: 10

    ColumnLayout {
        id: contents
        anchors.fill: parent
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: "transparent"
            Text {
                id: avText
                text: "Peers"
                color: T.Config.surfaceText
                font.pixelSize: 13
            }
        }

        Rectangle {
            id: listContainer
            color: "transparent"
            clip: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Math.max(column.implicitHeight, 300)

            ColumnLayout {
                id: column
                anchors.fill: parent
                spacing: 10

                Repeater {
                    model: S.Tailscale.peers

                    delegate: Rectangle {
                        implicitWidth: parent.width
                        // anchors.fill: parent
                        height: 30
                        radius: 6
                        anchors.margins: 10
                        color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Rectangle {
                                width: icon.implicitWidth
                                height: 22
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                Text {
                                    id: icon
                                    text: {
                                        if (modelData.connected) {
                                            return "󰱓";
                                        }
                                        return "󰅛";
                                    }
                                    font.pixelSize: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: modelData.connected ? T.Config.accent : T.Config.surfaceContainerHighest
                                }
                            }

                            Rectangle {
                                width: S.Tailscale.colHostWidth
                                height: 22
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                Text {
                                    text: modelData.hostName
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.tailscalePeersFontSize
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: S.Tailscale.colDnsWidth
                                height: 22
                                color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.dnsName
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.tailscalePeersFontSize
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: S.Tailscale.colIpWidth
                                height: 22
                                color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.ip
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.tailscalePeersFontSize
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Process {
                            id: wlcopy
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button == Qt.RightButton)
                                    wlcopy.command = ["wl-copy", modelData.ip];
                                else {
                                    wlcopy.command = ["wl-copy", modelData.dnsName];
                                }
                                wlcopy.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
