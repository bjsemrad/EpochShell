import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T

Rectangle {
    id: actionArea
    implicitHeight: T.Config.systemActionSize
    implicitWidth: T.Config.systemActionSize
    radius: T.Config.systemActionRadius
    color: actionMouseArea.containsMouse ? T.Config.activeSelection : "transparent"

    required property string icon
    required property string description
    function onClick() {
        console.log("Implementation Missing");
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: T.Config.systemActionSpacing

        Text {
            id: actionIcon
            text: icon
            font.pixelSize: T.Config.fontSizeLarge
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
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
