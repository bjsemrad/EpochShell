import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.theme as T

PopupWindow {
    id: popup
    visible: false
    color: "transparent"

    property var anim_CURVE_SMOOTH_SLIDE: [0.23, 1, 0.32, 1, 1, 1]

    default property alias content: contentLayout.data

    property int padding: T.Config.popupPadding
    property int bottomPadding: padding * 2
    property real popupWidth: 1

    // A ring of transparent space around the card.
    //
    // On a fractionally scaled output -- 1.333 on a 2880x1920 panel run at 2160x1440 -- the
    // window's last physical column and row can be rounded away, and they take the card's 1px
    // border with them: the panel renders with no right edge, or no bottom edge, depending on how
    // its size happens to round. Insetting the card by a whole logical pixel means the border is
    // never the outermost pixel, so there is nothing at the edge left to lose.
    readonly property int edgeInset: 1

    implicitWidth: popupWidth + edgeInset * 2
    implicitHeight: contentLayout.implicitHeight + padding + bottomPadding + edgeInset * 2

    property bool open: false

    function showPanel() {
        open = true;
        visible = true;
    }

    function hidePanel() {
        if (!stopHide) {
            open = false;
            visible = false;
            popupHover = false;
        }
    }

    property Item trigger: null

    property bool popupHover: false
    property bool stopHide: false

    function _updateHover() {
        if (!popupHover && !stopHide) {
            hidePanel();
        }
    }

    anchor {
        item: trigger
        edges: Edges.Left | Edges.Bottom
        gravity: Edges.Bottom | Edges.Middle
        adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip
        rect.y: trigger.mapToGlobal(0, 0).y + trigger.height + 5
    }

    Item {
        anchors.fill: parent

        ClippingRectangle {
            id: contentSection
            anchors.fill: parent
            anchors.margins: popup.edgeInset
            radius: T.Config.popupRadius
            color: T.Config.background
            border.width: 1
            border.color: T.Config.outline
            opacity: popup.visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: anim_CURVE_SMOOTH_SLIDE
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    popup.popupHover = hovered;
                    popup._updateHover();
                }
            }

            ColumnLayout {
                id: contentLayout
                anchors.fill: parent
                anchors.leftMargin: padding * 2
                anchors.rightMargin: padding * 2
                anchors.bottomMargin: bottomPadding
                anchors.topMargin: padding
                spacing: T.Config.popupLayoutSpacing
            }
        }
    }
}
