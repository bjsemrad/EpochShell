import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.theme as T

PopupWindow {
    id: popup
    visible: false
    color: "transparent"

    default property alias content: contentLayout.data
    readonly property int padding: 10
    property real popupWidth: 100
    implicitWidth:  popupWidth
    implicitHeight: contentLayout.implicitHeight + padding * 2

    property Item trigger: null

    property bool popupHover: false
    property bool stopHide: false

    function _updateHover() {
        if (!popupHover && !stopHide){
            popup.visible = false
        }
    }


    anchor {
        item: trigger
        edges: Edges.Left | Edges.Bottom
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip
    }


    Item {
        Window.onActiveChanged: { 
            if (!Window.active) {
                popup.visible = false
            }
        }
        anchors.fill: parent

        Rectangle {
            id: contentSection
            anchors.fill: parent
            radius: 8
            color: T.Config.bg
            border.color: T.Config.grey
            opacity: popup.visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: anim_CURVE_SMOOTH_SLIDE
                }
            }

            property var anim_CURVE_SMOOTH_SLIDE: [0.23, 1, 0.32, 1, 1, 1]

            HoverHandler {
                onHoveredChanged: {
                    popup.popupHover = hovered
                    popup._updateHover()
                }
            }

            ColumnLayout {
                id: contentLayout
                anchors.fill: parent
                anchors.margins: padding * 2
                spacing: 8
            }
        }
    }
}
