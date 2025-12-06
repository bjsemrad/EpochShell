import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as S
import qs.theme as T
import qs.commonwidgets

Rectangle {
    id: peersSection
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"

    implicitHeight: header.height + listContainer.height

    property real colHostWidth: 0
    property real colIpWidth:   0
    property real colDnsWidth: 0

    function measureWidth() {
        var maxH=0, maxI=0, maxS=0

        for (let p of S.Tailscale.peers) {
            maxH = Math.max(maxH, textMetrics(p.hostName))
            maxI = Math.max(maxI, textMetrics(p.ip))
            maxD = Math.max(maxD, textMetrics(p.dnsName))
        }

        colHostWidth = maxH + 10
        colIpWidth   = maxI + 10
        colDnsWidth = maxD + 10
    }

    function textMetrics(str) {
        var m = Qt.createQmlObject(
            'import QtQuick; Text { text:"' + str + '" }',
            table
        )
        var w = m.implicitWidth
        m.destroy()
        return w
    }

    Column {
        anchors.margins: 4
        anchors.fill: parent
        spacing: 6
        Rectangle {
            id: header
            implicitHeight: 20
            width: parent.width
            color: "transparent"
            Row {
                width: parent.width
                spacing: 10
                Text {
                    id: avText
                    text: "Peers"
                    color: T.Config.fg
                    font.pixelSize: 13
                    Layout.leftMargin: 4
                }
            }
        }


        Rectangle {
            id: listContainer
            radius: 6
            color: "transparent"
            clip: true
            width: parent.width
            implicitHeight: Math.max(column.implicitHeight, 300) + 20

            Column {
                id: column
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10

                Repeater {
                    model: S.Tailscale.peers

                    delegate: Rectangle {
                        width: parent.width
                        implicitHeight: 30
                        radius: 6
                        anchors.margins: 10
                        color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                        Row {
                            anchors.fill: parent
                            width: parent.width
                            height: 30
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text:  {
                                    if (modelData.connected) {
                                        return "󰱓"
                                    }
                                    return  "󰅛"
                                }
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.connected ? T.Config.green : T.Config.red
                            }

                            Rectangle {
                                width: S.Tailscale.colHostWidth; height: 22; color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.hostName
                                    color: T.Config.fg
                                    font.pixelSize: T.Config.tailscalePeersFontSize
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: S.Tailscale.colDnsWidth; height: 22; color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.dnsName
                                    color: T.Config.fg
                                    font.pixelSize: T.Config.tailscalePeersFontSize
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: S.Tailscale.colIpWidth; height: 22; color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.ip
                                    color: T.Config.fg
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
                            onClicked:(mouse)=> {
                                if (mouse.button == Qt.RightButton)
                                    wlcopy.command = ["wl-copy", modelData.ip]
                                else {
                                    wlcopy.command = ["wl-copy", modelData.dnsName]
                                }
                                wlcopy.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
