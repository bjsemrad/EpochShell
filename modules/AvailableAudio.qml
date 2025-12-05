import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme" as T
import "../commonwidgets"
import "../services" as S

Rectangle {
    id: audioSection
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"

    implicitHeight: header.height + listContainer.height

    required property string type
    required property PwNode defaultAudioNode

    function isAudioType(node){
        console.log("ERROR Missing Implementations")
    }

    function clickOperation(nodeId){
        S.AudioService.setDefault(nodeId)
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
                    text: "Available " + type
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
            implicitHeight: column.implicitHeight + 20

            Column {
                id: column
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10

                Repeater {
                    model: Pipewire.nodes

                    delegate: Rectangle {
                        width: parent.width
                        implicitHeight: 30
                        radius: 6
                        anchors.margins: 10
                        visible: isAudioType(modelData) && modelData.description
                        color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                        Row {
                            anchors.fill: parent
                            width: parent.width
                            anchors.margins: 10
                            spacing: 8


                            Text {
                                text:  ""
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.id === defaultAudioNode?.id ? T.Config.blue : T.Config.fg
                            }

                            Text {
                                text: modelData.description
                                color: "white"
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
                                clickOperation(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
