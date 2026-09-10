import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.theme as T
import qs.services as S

Rectangle {
    id: root
    color: mouseArea.containsMouse ? T.Config.surfaceContainer : "transparent"
    radius: T.Config.popupRadius
    implicitWidth: inner.implicitWidth + T.Config.barModuleHorizontalPadding
    implicitHeight: inner.implicitHeight + T.Config.barModuleVerticalPadding
    required property string iconText
    required property bool mouseEnabled
    property int fontPixelSize: T.Config.barIconSize
    property color iconColor: T.Config.surfaceText

    function performLeftClickAction() {
        console.log("Missing Implementation");
    }

    function performRightClickAction() {
        performLeftClickAction();
    }

    MouseArea {
        id: mouseArea
        enabled: mouseEnabled
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: mouseEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button == Qt.RightButton) {
                performRightClickAction();
            } else {
                performLeftClickAction();
            }
        }
    }

    Rectangle {
        id: inner
        implicitWidth: T.Config.barIconSize
        implicitHeight: T.Config.barIconSize
        color: "transparent"
        anchors.centerIn: parent
        Text {
            text: root.iconText
            font.pixelSize: root.fontPixelSize
            font.family: T.Config.fontFamily
            anchors.centerIn: parent
            color: root.iconColor
        }
    }
}
