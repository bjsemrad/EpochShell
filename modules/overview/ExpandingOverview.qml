import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.wifi
import qs.commonwidgets
import qs.theme as T

Rectangle {
    id: root
    Layout.fillWidth: true
    color: T.Config.surfaceContainer
    bottomLeftRadius: T.Config.cornerRadius
    bottomRightRadius: T.Config.cornerRadius
    Layout.preferredHeight: expanded ? height : 0
    height: expanded ? fullHeight : 0
    clip: true
    visible: false

    default property alias content: col.data
    property real fullHeight: col.implicitHeight + 10
    property bool expanded: false

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    function resetCard() {
        expanded = false;
        visible = false;
    }

    function openCard() {
        fullHeight = col.implicitHeight + 5;
        expanded = true;
        visible = true;
    }

    function closeCard() {
        expanded = false;
    }

    onImplicitHeightChanged: {
        if (!expanded && height === 0) {
            visible = false;
        }
    }

    Item {
        id: content
        anchors {
            fill: parent
            leftMargin: 12
            rightMargin: 12
            topMargin: 12
            bottomMargin: 12
        }
        clip: true
        ColumnLayout {
            id: col
            // Layout.fillWidth: true
            anchors.fill: parent
            clip: true
            onImplicitHeightChanged: {
                if (root.visible) {
                    openCard();
                }
            }
        }
    }
}
