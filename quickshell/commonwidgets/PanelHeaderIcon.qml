import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import Quickshell.Io
import qs.theme as T

Rectangle {
    id: panelHeaderIcon
    implicitWidth: 40
    implicitHeight: 40
    radius: 20
    border.width: 1
    border.color: headerMouseArea.containsMouse ? T.Config.surfaceText : "transparent"
    color: headerMouseArea.containsMouse ? T.Config.activeSelection : "transparent"
    Layout.alignment: Qt.AlignVCenter
    // anchors.verticalCenter: parent.verticalCenter

    required property string iconText
    function onClick() {
        console.log("Implementation missing");
    }

    Text {
        text: iconText
        font.pixelSize: 18
        anchors.verticalCenter: parent.verticalCenter
        anchors.centerIn: parent
        color: T.Config.surfaceText
    }
    MouseArea {
        id: headerMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            onClick();
        }
    }
}
