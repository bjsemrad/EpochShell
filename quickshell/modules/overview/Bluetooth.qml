import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.bluetooth
import qs.commonwidgets
import qs.theme as T

ExpandingOverview {
    BluetoothOnOff {}
    ComponentSplitter {}
    BluetoothPairedDevices {}
    ComponentSplitter {}
    BluetoothAvailableDevices {
        bgColor: T.Config.surface
    }
    ComponentSpacer {}
}
