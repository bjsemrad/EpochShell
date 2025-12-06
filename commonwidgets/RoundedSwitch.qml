import QtQuick
import QtQuick.Controls
import qs.theme as T

Item {
    id: root
    width: 42
    height: 24
    property bool checked: false
    signal toggled()

    // Background track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: checked ? T.Config.blue : T.Config.bg3
        Behavior on color { ColorAnimation { duration: 160 } }
    }

    // Knob
    Rectangle {
        id: knob
        width: 20
        height: 20
        radius: 10
        y: 2
        x: checked ? (root.width - width - 2) : 2
        color: T.Config.bg0

        Behavior on x {
            NumberAnimation {
                duration: 160
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color { ColorAnimation { duration: 160 } }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: {
            root.checked = !root.checked
            root.toggled()
        }
    }
}
