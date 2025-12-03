import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../commonwidgets"
import "../modules"
import "../theme" as T
import "../services" as S

HoverPopupWindow {
    id: systemOptionsPopup
    trigger: trigger

    Row {
        id: systemContent
        spacing: 10
        Column {
            width: T.Config.systemPopupWidth
            spacing: 10
            SystemOptionsHeader{}
            ComponentSplitter{}
            SystemActions{}
            ComponentSpacer{}
        }
    }

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(systemOptionsPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(systemOptionsPopup)
    }
}

