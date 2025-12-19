import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T
import qs.commonwidgets
import qs.services as S

Item {
    id: audioSection
    Layout.fillWidth: true
    Layout.preferredHeight: header.height + listContainer.height

    required property string type
    required property PwNode defaultAudioNode

    function isAudioType(node) {
        console.log("ERROR Missing Implementations");
    }

    function clickOperation(nodeId) {
        S.AudioService.setDefault(nodeId);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: "transparent"
            RowLayout {
                width: parent.width
                spacing: 10
                Text {
                    id: avText
                    text: "Available " + type
                    color: T.Config.surfaceText
                    font.pixelSize: 13
                }
            }
        }

        Rectangle {
            id: listContainer
            radius: 6
            color: "transparent"
            clip: true
            Layout.fillWidth: true
            Layout.preferredHeight: column.implicitHeight + 20

            ColumnLayout {
                id: column
                anchors.fill: parent
                spacing: 10

                Repeater {
                    model: Pipewire.nodes

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        visible: isAudioType(modelData) && modelData.description
                        color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8
                            Text {
                                text: ""
                                font.pixelSize: 18
                                Layout.alignment: Qt.AlignVCenter
                                color: modelData.id === defaultAudioNode?.id ? T.Config.accent : T.Config.surfaceText
                            }

                            Text {
                                text: modelData.description
                                color: T.Config.surfaceText
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                clip: true
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
                                clickOperation(modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }
}
