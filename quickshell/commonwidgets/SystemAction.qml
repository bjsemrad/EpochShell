import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T

Rectangle {
    id: contents
    Layout.fillWidth: true
    Layout.preferredHeight: T.Config.systemActionSize
    radius: T.Config.systemActionRadius
    color: "transparent"
    required property string icon
    required property string description
    function onClick() {
        console.log("Implementation Missing");
    }

    Rectangle {
        id: actionArea
        implicitHeight: T.Config.systemActionSize
        width: parent.width
        radius: T.Config.systemActionRadius
        color: actionMouseArea.containsMouse ? T.Config.surfaceContainerHigh : "transparent"

        // Anchored on both sides, so a label longer than the row elides inside the highlight
        // instead of running past its right edge.
        RowLayout {
            anchors.leftMargin: T.Config.systemActionMargin
            anchors.rightMargin: T.Config.systemActionSpacing
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: T.Config.systemActionSpacing

            Rectangle {
                Layout.preferredWidth: 24
                Layout.fillHeight: true
                color: "transparent"

                Text {
                    id: actionIcon
                    text: icon
                    font.pixelSize: T.Config.fontSizeLarge
                    anchors.centerIn: parent
                    color: T.Config.surfaceText
                }
            }

            Text {
                id: actionText
                text: description
                font.pixelSize: T.Config.fontSizeLarge
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
                color: T.Config.surfaceText
            }
        }

        MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                onClick();
            }
        }
    }
}
