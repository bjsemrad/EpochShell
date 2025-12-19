import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.services as S
import qs.theme as T
import qs.commonwidgets

Item {
    id: pairedDevices
    Layout.fillWidth: true
    Layout.preferredHeight: column.implicitHeight

    property string pendingSsid: ""
    property int pendingIndex: -1

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Paired Devices"
            color: T.Config.surfaceText
            font.pixelSize: 13
        }

        Repeater {
            model: S.Bluetooth.pairedDevices

            delegate: BluetoothPairedRow {
                device: modelData
            }
        }
    }
}
