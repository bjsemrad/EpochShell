import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import '../theme' as T
import '../services' as S
Rectangle {
    id: root
    color: "transparent"
    implicitWidth: inner.implicitWidth + 5
    implicitHeight: inner.implicitHeight + 5
    property var popup
    required property string iconText
    required property bool mouseEnabled
    required property bool hoverEnabled

    MouseArea {
        id: mouseArea
        enabled: mouseEnabled
        anchors.fill: parent
        hoverEnabled: hoverEnabled
        cursorShape: mouseEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            popup.visible = !popup.visible
        }

        onEntered: {
            popup.visible = mouseArea.containsMouse
        }

        onExited: {
            popup.visible = !mouseArea.containMouse
        }
    }

    Row {
        id: inner
        height: parent.height
        spacing: 5 
        Text {
            text: root.iconText
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
            color: T.Config.fg
        }
    }
}
