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
    id: batteryPopup
    trigger: trigger
    popupWidth:  T.Config.batteryPopupWidth

    BatteryLevel{}
    ComponentSpacer{}

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(batteryPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(batteryPopup)
    }
}

