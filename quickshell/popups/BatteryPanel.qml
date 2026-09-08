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
    popupWidth: T.Config.batteryPopupWidth

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Battery"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    ComponentSplitter {}

    BatteryLevel{}

    ComponentSpacer{ bottomMargin: 6 }

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(batteryPopup)
        }
    }

    Component.onDestruction: S.PopupManager.unregister(batteryPopup)
    Component.onCompleted: {
        S.PopupManager.register(batteryPopup, "battery")
    }
}

