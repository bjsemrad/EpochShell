import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    radius: 6
    color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

    property BluetoothDevice device

    Rectangle {
        width: row.implicitWidth
        height: parent.height
        color: "transparent"
        RowLayout {
            id: row
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width

            Text {
                text: S.Bluetooth.getDeviceIcon(device)
                font.pixelSize: 18
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 10
                color: device.state === BluetoothDeviceState.Connected ? T.Config.accent : T.Config.surfaceText
            }

            Text {
                text: device.name
                Layout.alignment: Qt.AlignVCenter
                color: T.Config.surfaceText
                font.pixelSize: 13
            }

            Spinner {
                id: bluetoothSpinner
                running: device.state === BluetoothDeviceState.Connecting
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (device.state === BluetoothDeviceState.Connected) {
                    device.disconnect();
                } else {
                    device.connect();
                }
            }
        }
    }
}
