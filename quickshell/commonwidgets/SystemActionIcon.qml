import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.theme as T

Rectangle {
    id: actionArea
    implicitHeight: 40
    implicitWidth: 40
    radius: 10
    color: actionMouseArea.containsMouse ? T.Config.activeSelection : "transparent"

    required property string icon
    required property string description
    function onClick() {
        console.log("Implementation Missing");
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 10

        Text {
            id: actionIcon
            text: icon
            font.pixelSize: 18
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
