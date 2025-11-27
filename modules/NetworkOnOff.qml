import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../theme" as T
import "../services" as S
import "../commonwidgets"

// NetworkHeaderRow.qml
import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: parent.width
    height: 30
    radius: 40
    color: "transparent"

    // "wifi" or "ethernet"
    property string mode: "wifi"

    // fired when user clicks anywhere on the row (to open popup)
    signal activated()

    // derived status line
    property string subtitle: {
        if (mode === "wifi") {
            if (!S.NetworkMonitor.wifiEnabled)
                return "Off"
            if (S.NetworkMonitor.connected && S.NetworkMonitor.ssid)
                return S.NetworkMonitor.ssid
            return "Not connected"
        } else { // ethernet – you can adapt this to your own ethernet monitor later
            return S.NetworkMonitor.connected ? "Connected" : "Not connected"
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Column {
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width*.75
            Text {
                text: mode === "wifi" ? "Wi-Fi" : "Ethernet"
                color: "white"
                font.bold: true
                font.pointSize: 11
            }
        }

        Column {
            width: parent.width*.25
            height: parent.height
            anchors.right: parent.right
            anchors.rightMargin: 10
            spacing: 8
            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                width: parent.width
                height: parent.height


                RoundedSwitch{
                    id: wifiSwitch
                    visible: mode === "wifi"
                    anchors.verticalCenter: parent.verticalCenter
                    checked: S.NetworkMonitor.wifiEnabled
                    onToggled: {
                        S.NetworkMonitor.disableWifi(wifiSwitch.checked)
                    }
                }


                Rectangle {
                    id: networkSettings
                    implicitWidth: 40;
                    implicitHeight: 40
                    radius: 20
                    border.width: 2
                    border.color: settingsMouseArea.containsMouse ? T.Config.blue : "transparent"
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: ""
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.centerIn: parent
                        color: "white"
                    }
                    MouseArea {
                        id: settingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            S.NetworkMonitor.editNetworks()
                        }

                    }
                }
            }
        }
     }
}
