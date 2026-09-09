import QtQuick
import QtCore
import QtQuick.Dialogs
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

// Pick a file to send. The transfer itself starts when a device is chosen below.
Item {
    id: picker
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
                    text: S.LocalSend.selectedFile.length > 0 ? "󰈔" : "󰈙"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeMedium
                    font.family: T.Config.fontFamily
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: S.LocalSend.selectedFile.length > 0 ? S.LocalSend.fileName(S.LocalSend.selectedFile) : "Choose a file to send"
                    color: S.LocalSend.selectedFile.length > 0 ? T.Config.surfaceText : T.Config.outline
                    font.pixelSize: T.Config.fontSizeNormal
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    visible: S.LocalSend.selectedFile.length > 0
                    text: "󰅖"
                    color: clearMouse.containsMouse ? T.Config.red : T.Config.outline
                    font.pixelSize: T.Config.fontSizeMedium
                    font.family: T.Config.fontFamily
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: S.LocalSend.clearSelectedFile()
                    }
                }
            }

            MouseArea {
                id: pickerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                // The clear button sits on top and handles its own clicks.
                onClicked: fileDialog.open()
            }
        }

        Text {
            visible: S.LocalSend.sendStatus.length > 0
            text: S.LocalSend.sendStatus
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    FileDialog {
        id: fileDialog
        title: "Send with LocalSend"
        currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        onAccepted: S.LocalSend.selectFile(selectedFile)
        // The panel hides on focus loss, so it has to be pinned while the dialog is up.
        onVisibleChanged: {
            if (picker.popupWindow) picker.popupWindow.stopHide = visible;
        }
    }
}
