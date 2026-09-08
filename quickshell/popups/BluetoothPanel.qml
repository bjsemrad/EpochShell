import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.modules.bluetooth
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: bluetoothPopup
    trigger: trigger
    popupWidth:  T.Config.bluetoothPopupWidth

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(bluetoothPopup)
        }
    }

    Component.onDestruction: S.PopupManager.unregister(bluetoothPopup)
    Component.onCompleted: {
        S.PopupManager.register(bluetoothPopup, "bluetooth")
    }

    BluetoothOnOff {}
    ComponentSplitter{}
    BluetoothPairedDevices{}
    ComponentSplitter{}
    BluetoothAvailableDevices{}
    ComponentSpacer { bottomMargin: 6 }
}
