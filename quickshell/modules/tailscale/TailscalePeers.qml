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

    property bool useBackground: false

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
            color: peersSection.useBackground ? T.Config.surface : "transparent"
            clip: true
            radius: T.Config.cardRadius
            border.width: 1
            border.color: peersSection.useBackground ? T.Config.surfaceVariant : "transparent"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: Math.min(peersFlick.contentHeight, 300)

            Flickable {
                id: peersFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: column.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: column
                    width: peersFlick.width
                    spacing: 10

                    Repeater {
                        model: S.Tailscale.peers

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            radius: 6
                            color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                            Row {
                                z: 1
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                    rightMargin: 10
                                }
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

                                Rectangle {
                                    // Same send affordance as the LocalSend panel: a glyph that
                                    // shows what clicking will do, rather than a labelled button.
                                    visible: S.Tailscale.selectedFile.length > 0
                                    width: 24
                                    height: 24
                                    radius: 6
                                    color: sendMouse.containsMouse && sendMouse.enabled ? T.Config.activeSelection : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: S.Tailscale.sendingFile && S.Tailscale.sendTarget === modelData.taildropTarget ? "󰔟" : "󰅧"
                                        color: T.Config.accent
                                        font.pixelSize: T.Config.fontSizeMedium
                                        font.family: T.Config.fontFamily
                                    }

                                    MouseArea {
                                        id: sendMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        enabled: !S.Tailscale.sendingFile && modelData.taildropTarget.length > 0
                                        onClicked: mouse => {
                                            mouse.accepted = true;
                                            S.Tailscale.sendFile(modelData);
                                        }
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

                ScrollBar.vertical: ScrollBar {
                    policy: peersFlick.contentHeight > peersFlick.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    contentItem: Rectangle {
                        implicitWidth: 3
                        radius: 3
                        color: T.Config.surfaceText
                        opacity: 0.7
                    }
                }
            }
        }
    }
}
