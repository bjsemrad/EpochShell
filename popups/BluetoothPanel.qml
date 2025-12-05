import Quickshell
import Quickshell.Wayland        // for WlrLayershell + WlrLayer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../commonwidgets"
import "../modules"
import "../theme" as T
import "../services" as S

HoverPopupWindow {
    id: bluetoothPopup
    trigger: trigger

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(bluetoothPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(bluetoothPopup)
    }


    Column {
        width: T.Config.bluetoothPopupWidth
        spacing: 10
        BluetoothOnOff {}
        ComponentSplitter{}
        BluetoothPairedDevices{}
        ComponentSplitter{}
        BluetoothAvailableDevices{}
        ComponentSpacer{}
    }
}

