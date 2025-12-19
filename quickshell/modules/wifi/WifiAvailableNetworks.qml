import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Item {
    id: networksSection
    Layout.fillWidth: true
    Layout.preferredHeight: col.implicitHeight
    Layout.bottomMargin: 10
    clip: true

    property bool expanded: false
    required property var attachedPanel
    property string bgColor: T.Config.background

    Connections {
        target: attachedPanel
        function onVisibleChanged() {
            if (!attachedPanel.visible)
                networksSection.expanded = false;
        }
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        spacing: 6
        Rectangle {
            id: header
            Layout.preferredHeight: 20
            Layout.fillWidth: true
            color: "transparent"
            RowLayout {
                width: parent.width
                spacing: 10
                Text {
                    id: avText
                    text: "Available Networks"
                    color: T.Config.surfaceText
                    font.pixelSize: 13
                    Layout.leftMargin: 4
                }

                Text {
                    text: expanded ? "" : "▼"
                    color: T.Config.surfaceText
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
                cursorShape: networksSection.expanded ? Qt.ArrowCursor : Qt.PointingHandCursor

                onClicked: function () {
                    if (!networksSection.expanded) {
                        S.Network.refreshAvailable();
                    }
                    networksSection.expanded = true; //!networksSection.expanded;
                }
            }
        }

        Rectangle {
            id: listContainer
            radius: 6
            color: bgColor
            clip: true
            border.width: 2
            border.color: T.Config.surfaceVariant
            Layout.fillWidth: true
            Layout.preferredHeight: networksSection.expanded ? Math.min(networkList.contentHeight, 300) : 0

            ListView {
                id: networkList
                anchors.fill: parent
                implicitHeight: Math.min(listContainer.implicitHeight, 100)
                model: S.Network.accessPoints
                interactive: true

                delegate: Rectangle {
                    width: ListView.view.width * .95
                    implicitHeight: 30
                    radius: 6
                    color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                    RowLayout {
                        id: row
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: {
                                const s = modelData.strength;

                                if (s >= 75)
                                    return "󰤨";
                                if (s >= 50)
                                    return "󰤢";
                                if (s >= 25)
                                    return "󰤟";
                                return "󰤟";
                            }
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 10
                            color: T.Config.surfaceText
                        }

                        Text {
                            text: modelData.ssid
                            color: T.Config.surfaceText
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            S.Network.connectTo(modelData.ssid);
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
