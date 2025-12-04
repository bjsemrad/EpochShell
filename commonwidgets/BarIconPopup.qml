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

    Row {
        id: inner
        height: parent.height
        spacing: 5 
        Text {
            text: root.iconText
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
            color: T.Config.fg

             MouseArea {
                id: mouseArea
                enabled: mouseEnabled
                anchors.fill: parent
                hoverEnabled: root.hoverEnabled
                cursorShape: mouseEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if(!popup.visible) {
                        popup.visible = true //Don't set this to !popup.visible, on high-refresh get odd flickering
                    }
                }

                onEntered: {
                    popup.visible = mouseArea.containsMouse
                }

                onExited: {
                    popup.visible = !mouseArea.containMouse
                }
            }
        }
    }
}
