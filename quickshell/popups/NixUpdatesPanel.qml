import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.modules.battery
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: nixUpdatesPopup
    trigger: trigger
    popupWidth: 700

    Flickable {
        id: flick
        Layout.fillWidth: true
        Layout.fillHeight: true

        contentWidth: popupWidth
        contentHeight: updateText.height

        implicitHeight: Math.min(contentHeight + 10, Screen.height - (Screen.height / 15))
        implicitWidth: popupWidth + 10

        clip: true

        Text {
            id: updateText
            text: S.NixService.updateText
            color: T.Config.surfaceText
        }
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            opacity: flick.moving ? 1 : 0.0

            contentItem: Rectangle {
                implicitWidth: 3
                radius: 3
                color: T.Config.surfaceText
            }
        }
    }
    ComponentSpacer {}

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(nixUpdatesPopup);
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(nixUpdatesPopup);
    }
}
