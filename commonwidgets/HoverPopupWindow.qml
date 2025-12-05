import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../theme" as T
PopupWindow {
    id: root
    visible: false
    color: "transparent"
    implicitWidth: container.implicitWidth + 20
    implicitHeight: container.implicitHeight + 20

    property Item trigger: null
    default property alias content: container.data

    property bool _popupHover: false

    function _updateHover() {
        if (!_popupHover){
            root.visible = false
        }
    }

    Window.onActiveChanged: {
        if (!Window.active) {
            root.visible = false
        }
    }

     // --- SHADOW ---
    DropShadow {
        id: shadow
        anchors.fill: bg    // shadow covers popup area
        source: bg
        radius: 12          // softness of shadow
        samples: 24         // quality
        horizontalOffset: 0
        verticalOffset: 6   // pushes shadow downward a bit
        color: "#00000080"  // 50% opacity black
    }

    anchor {
        item: trigger
        edges: Edges.Left | Edges.Bottom
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: T.Config.black
        border.color: T.Config.grey

        HoverHandler {
            onHoveredChanged: {
                root._popupHover = hovered
                root._updateHover()
            }
        }

        Column {
            id: container
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
        }
    }
}
