import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.theme as T
import qs.services as S

Rectangle {
    id: root
    border.width: 1
    color: popup.open ? T.Config.surfaceContainer : mouseArea.containsMouse ? T.Config.surfaceContainer : "transparent"
    radius: T.Config.popupRadius
    implicitWidth: inner.implicitWidth + T.Config.barModuleHorizontalPadding
    implicitHeight: inner.implicitHeight + verticalPadding

    property var popup
    required property string iconText
    required property bool mouseEnabled
    required property bool hoverEnabled
    property int fontPixelSize: T.Config.barIconSize
    property int verticalPadding: T.Config.barModuleVerticalPadding
    property color iconColor: T.Config.surfaceText
    property alias isHovered: mouseArea.containsMouse

    MouseArea {
        id: mouseArea
        enabled: mouseEnabled
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: mouseEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked();
                return;
            }
            if (popup.visible) {
                popup.hidePanel();
            } else {
                popup.showPanel();
            }
        }

        onEntered: {
            if (root.hoverEnabled) {
                if (mouseArea.containsMouse) {
                    popup.showPanel();
                } else {
                    popup.hidePanel();
                }
            }
        }

        onExited: {
            if (root.hoverEnabled) {
                if (!mouseArea.containsMouse) {
                    popup.hidePanel();
                }
            }
        }
    }

    signal rightClicked()

    Rectangle {
        id: inner
        implicitWidth: T.Config.barIconSize
        implicitHeight: T.Config.barIconSize
        color: "transparent"
        anchors.centerIn: parent
        Text {
            id: iconText
            text: root.iconText
            font.pixelSize: root.fontPixelSize
            font.family: T.Config.fontFamily
            anchors.centerIn: parent
            color: root.iconColor
        }
    }
}
