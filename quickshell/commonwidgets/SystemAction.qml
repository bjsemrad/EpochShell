import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T

Rectangle {
    id: contents
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    radius: 10
    color: "transparent"
    required property string icon
    required property string description
    function onClick() {
        console.log("Implementation Missing");
    }

    Rectangle {
        id: actionArea
        implicitHeight: 40
        width: parent.width
        radius: 10
        color: actionMouseArea.containsMouse ? T.Config.activeSelection : "transparent"

        RowLayout {
            anchors.leftMargin: 30
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                id: actionIcon
                text: icon
                font.pixelSize: 18
                Layout.alignment: Qt.AlignVCenter
                color: T.Config.surfaceText
            }

            Text {
                id: actionText
                text: description
                font.pixelSize: 18
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
