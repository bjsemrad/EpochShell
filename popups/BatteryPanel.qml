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
    id: batteryPopup
    trigger: trigger

    Row {
        id: batteryContent
        spacing: 10
        Column {
            width: T.Config.batteryPopupWidth
            spacing: 10
            BatteryLevel{}
            ComponentSpacer{}
        }
    }

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(batteryPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(batteryPopup)
    }
}

