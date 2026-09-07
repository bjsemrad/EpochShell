import QtQuick
import QtCore
import QtQuick.Dialogs
import QtQuick.Layouts
import qs.commonwidgets
import qs.services as S
import qs.theme as T

Item {
    id: taildrop
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
                text: "Taildrop"
                color: T.Config.surfaceText
                font.pixelSize: 13
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            radius: T.Config.roundRadius
            color: pickerMouse.containsMouse ? T.Config.surfaceContainerHigh : T.Config.surface
            border.width: 1
            border.color: T.Config.outline

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 8

                Text {
                    text: S.Tailscale.selectedFile.length > 0 ? "󰈔" : "󰈙"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeMedium
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: S.Tailscale.selectedFile.length > 0 ? S.Tailscale.fileName(S.Tailscale.selectedFile) : "Choose file to send"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeNormal
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            MouseArea {
                id: pickerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: fileDialog.open()
            }
        }

        RowLayout {
            visible: S.Tailscale.selectedFile.length > 0 || S.Tailscale.sendStatus.length > 0
            Layout.fillWidth: true
            spacing: T.Config.layoutSpacingSmall

            Text {
                text: S.Tailscale.sendStatus
                color: S.Tailscale.sendingFile ? T.Config.accent : T.Config.inactive
                font.pixelSize: T.Config.fontSizeSubtext
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                visible: S.Tailscale.selectedFile.length > 0
                Layout.preferredWidth: clearText.implicitWidth + T.Config.popupPadding
                Layout.preferredHeight: 24
                radius: T.Config.roundRadius
                color: clearMouse.containsMouse ? T.Config.surfaceContainerHigh : T.Config.surface

                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "Clear"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeSubtext
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: S.Tailscale.clearSelectedFile()
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Send with Tailscale"
        fileMode: FileDialog.OpenFile
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        onAccepted: {
            S.Tailscale.selectFile(selectedFile);
            Qt.callLater(() => {
                if (taildrop.popupWindow) taildrop.popupWindow.showPanel();
            });
        }
    }
}
