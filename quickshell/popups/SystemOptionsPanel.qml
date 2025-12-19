import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: systemOptionsPopup
    trigger: trigger
    popupWidth: T.Config.systemPopupWidth

    SystemOptionsHeader{}
    ComponentSplitter{}
    SystemActions{}
    ComponentSpacer{}

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(systemOptionsPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(systemOptionsPopup)
    }
}

