import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.bluetooth
import qs.commonwidgets

ColumnLayout {
    BluetoothOnOff {}
    ComponentSplitter{}
    BluetoothPairedDevices{}
    ComponentSplitter{}
    BluetoothAvailableDevices{}
    ComponentSpacer{}
}
