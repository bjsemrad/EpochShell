import QtQuick
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

Item {
    id: receive
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight
    Layout.bottomMargin: 6

    ColumnLayout {
        id: contents
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: T.Config.layoutMarginSmall

            Text {
                text: "Receive Files"
                color: T.Config.surfaceText
                font.pixelSize: 13
                Layout.fillWidth: true
            }

            Text {
                text: S.LocalSend.receivingAvailable ? S.LocalSend.downloadDir : "Receiver unavailable"
                color: S.LocalSend.receivingAvailable ? T.Config.outline : T.Config.red
                font.pixelSize: T.Config.fontSizeSubtext
                elide: Text.ElideMiddle
                Layout.maximumWidth: 210
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: S.LocalSend.hasIncomingFiles ? Math.min(incomingList.contentHeight + 18, 150) : 34
            radius: T.Config.roundRadius
            color: T.Config.surface
            border.width: 1
            border.color: S.LocalSend.hasIncomingFiles ? T.Config.accent : T.Config.outline
            clip: true

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 8
                }
                spacing: 4

                Text {
                    visible: !S.LocalSend.hasIncomingFiles
                    text: S.LocalSend.receiveStatus.length > 0 ? S.LocalSend.receiveStatus : "No incoming files"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeNormal
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Flickable {
                    id: incomingList
                    visible: S.LocalSend.hasIncomingFiles
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 132)
                    contentWidth: width
                    contentHeight: incomingColumn.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: incomingColumn
                        width: incomingList.width
                        spacing: 8

                        Repeater {
                            model: S.LocalSend.incomingTransfers

                            delegate: ColumnLayout {
                                id: transferRow
                                required property var modelData
                                readonly property string session: String(modelData.session || "")
                                width: incomingColumn.width
                                spacing: 4

                                RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    Text {
                                        text: "󰒍"
                                        color: T.Config.accent
                                        font.pixelSize: T.Config.fontSizeNormal
                                        font.family: T.Config.fontFamily
                                    }

                                    Text {
                                        text: String(modelData.device || "Unknown device")
                                        color: T.Config.surfaceText
                                        font.pixelSize: T.Config.fontSizeNormal
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: (modelData.files || []).length + " file" + ((modelData.files || []).length === 1 ? "" : "s")
                                        color: T.Config.inactive
                                        font.pixelSize: T.Config.fontSizeSubtext
                                    }
                                }

                                Repeater {
                                    model: modelData.files || []

                                    delegate: RowLayout {
                                        width: incomingColumn.width
                                        spacing: 8

                                        Text {
                                            text: "󰈔"
                                            color: T.Config.outline
                                            font.pixelSize: T.Config.fontSizeSubtext
                                        }

                                        Text {
                                            text: modelData.name || "Unnamed file"
                                            color: T.Config.surfaceText
                                            font.pixelSize: T.Config.fontSizeSubtext
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: S.LocalSend.formatBytes(modelData.size || 0)
                                            color: T.Config.inactive
                                            font.pixelSize: T.Config.fontSizeSubtext
                                        }
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 6

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 26
                                        radius: T.Config.roundRadius
                                        color: acceptMouse.containsMouse ? T.Config.accentLightShade : T.Config.surfaceContainer
                                        border.width: 1
                                        border.color: T.Config.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Accept"
                                            color: T.Config.surfaceText
                                            font.pixelSize: T.Config.fontSizeSubtext
                                        }

                                        MouseArea {
                                            id: acceptMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: S.LocalSend.acceptTransfer(transferRow.session)
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 26
                                        radius: T.Config.roundRadius
                                        color: declineMouse.containsMouse ? T.Config.surfaceContainerHigh : T.Config.surfaceContainer

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Decline"
                                            color: T.Config.outline
                                            font.pixelSize: T.Config.fontSizeSubtext
                                        }

                                        MouseArea {
                                            id: declineMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: S.LocalSend.declineTransfer(transferRow.session)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
