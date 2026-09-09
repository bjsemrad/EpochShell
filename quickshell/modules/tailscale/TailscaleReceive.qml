import QtQuick
import QtCore
import QtQuick.Dialogs
import QtQuick.Layouts
import qs.commonwidgets
import qs.services as S
import qs.theme as T

Item {
    id: receive
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight
    Layout.bottomMargin: 6
    property var popupWindow: null

    ColumnLayout {
        id: contents
        anchors.fill: parent
        spacing: 4

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
            color: "transparent"

            Text {
                text: "Receive Taildrop"
                color: T.Config.surfaceText
                font.pixelSize: 13
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: S.Tailscale.hasIncomingFiles ? Math.min(incomingList.contentHeight + 18, 110) : 34
            radius: T.Config.roundRadius
            color: T.Config.surface
            border.width: 1
            border.color: S.Tailscale.hasIncomingFiles ? T.Config.accent : T.Config.outline
            clip: true

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 8
                }
                spacing: 4

                Text {
                    visible: !S.Tailscale.hasIncomingFiles
                    text: S.Tailscale.receiveStatus.length > 0 ? S.Tailscale.receiveStatus : "No files waiting"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeNormal
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Flickable {
                    id: incomingList
                    visible: S.Tailscale.hasIncomingFiles
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 92)
                    contentWidth: width
                    contentHeight: incomingColumn.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: incomingColumn
                        width: incomingList.width
                        spacing: 3

                        Repeater {
                            model: S.Tailscale.incomingFiles

                            delegate: RowLayout {
                                width: incomingColumn.width
                                spacing: 8

                                Text {
                                    text: "󰈔"
                                    color: T.Config.accent
                                    font.pixelSize: T.Config.fontSizeNormal
                                }

                                Text {
                                    text: modelData.name || "Unnamed file"
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.fontSizeNormal
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: S.Tailscale.formatBytes(modelData.size || 0)
                                    color: T.Config.inactive
                                    font.pixelSize: T.Config.fontSizeSubtext
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: T.Config.layoutSpacingSmall

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: T.Config.roundRadius
                color: receiveMouse.containsMouse ? T.Config.accentLightShade : T.Config.surface
                border.width: 1
                border.color: S.Tailscale.hasIncomingFiles ? T.Config.accent : T.Config.outline

                Text {
                    anchors.centerIn: parent
                    text: S.Tailscale.receivingFiles ? "Receiving..." : "Choose Save Folder"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeNormal
                }

                MouseArea {
                    id: receiveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !S.Tailscale.receivingFiles
                    onClicked: folderDialog.open()
                }
            }

            Rectangle {
                Layout.preferredWidth: refreshText.implicitWidth + T.Config.popupPadding
                Layout.preferredHeight: 28
                radius: T.Config.roundRadius
                color: refreshMouse.containsMouse ? T.Config.surfaceContainerHigh : T.Config.surface

                Text {
                    id: refreshText
                    anchors.centerIn: parent
                    text: "Check"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeSubtext
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: S.Tailscale.refreshIncoming()
                }
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Save Taildrop files"
        currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        onAccepted: {
            S.Tailscale.receiveFiles(selectedFolder);
            Qt.callLater(() => {
                if (receive.popupWindow) receive.popupWindow.showPanel();
            });
        }
    }
}
