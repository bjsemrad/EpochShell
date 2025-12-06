import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Rectangle {
    id: networksSection
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"

    property bool expanded: false
    implicitHeight: header.height + listContainer.height + 10


    Connections {
        target: wifiNetworkPanel
        function onVisibleChanged() {
            if (!wifiNetworkPanel.visible) networksSection.expanded = false
        }
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
                    text: "Available Networks"
                    color: T.Config.fg
                    font.pixelSize: 13
                    Layout.leftMargin: 4
                }

                Text {
                    text: expanded ? "▲" : "▼"
                    color: T.Config.fg 
                    font.pixelSize: 12
                }

                Spinner {
                    id: wifiSpinner
                    running: S.Network.wifiScanning
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: function() {
                    if(!networksSection.expanded) {
                        S.Network.refreshAvailable()
                    }
                    networksSection.expanded = !networksSection.expanded

                }
            }
        }


        Rectangle {
            id: listContainer
            radius: 6
            color: T.Config.bg
            clip: true
            border.width: 2
            border.color: T.Config.bg2
            width: parent.width
            implicitHeight: networksSection.expanded
                    ? Math.min(networkList.contentHeight, 300)
                    : 0

            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutQuad
                }
            }

            ListView {
                id: networkList
                anchors.fill: parent
                implicitHeight: Math.min(listContainer.implicitHeight,  100)
                model: S.Network.accessPoints
                interactive: true

                delegate: Rectangle {
                    width: ListView.view.width*.9
                    implicitHeight: 30
                    radius: 6
                    anchors.margins: 10
                    color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                    Row {
                        anchors.fill: parent
                        width: parent.width
                        anchors.margins: 10
                        spacing: 8


                        Text {
                            text:  {
                                const s = modelData.strength

                                if (s >= 75) return "󰤨"
                                if (s >= 50) return "󰤢"
                                if (s >= 25) return "󰤟"
                                return "󰤟"
                            }
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            color: T.Config.fg
                        }
 
                        Text {
                            text: modelData.ssid
                            color: T.Config.fg
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                           S.Network.connectTo(modelData.ssid) 
                        }
                    }
                }
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }
            }
        }
    }
}
