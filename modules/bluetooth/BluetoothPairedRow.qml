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
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    radius: 6
    height: 30
    color: "transparent"

    property BluetoothDevice device

    Row {
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Rectangle {
            radius: 6
            color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"
            implicitWidth: parent.width
            implicitHeight: parent.height
             Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.left: parent.left
                    width: parent.width


                    Text {
                        text: S.Bluetooth.getDeviceIcon(device)
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        color: device.state === BluetoothDeviceState.Connected ? T.Config.green : T.Config.fg
                    }

                    Text {
                        text: device.name
                        anchors.verticalCenter: parent.verticalCenter
                        color: T.Config.fg
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
                        if(device.state === BluetoothDeviceState.Connected){
                            device.disconnect()
                        }else{
                            device.connect()
                        }
                    }
                }
        }
    }
}
