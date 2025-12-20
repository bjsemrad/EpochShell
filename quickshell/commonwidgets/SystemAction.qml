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
        color: actionMouseArea.containsMouse ? T.Config.activeSelection : "transparent"

        RowLayout {
            anchors.leftMargin: T.Config.systemActionMargin
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: T.Config.systemActionSpacing

            Text {
                id: actionIcon
                text: icon
                font.pixelSize: T.Config.fontSizeLarge
                Layout.alignment: Qt.AlignVCenter
                color: T.Config.surfaceText
            }

            Text {
                id: actionText
                text: description
                font.pixelSize: T.Config.fontSizeLarge
                Layout.alignment: Qt.AlignVCenter
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
