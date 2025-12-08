import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Greetd
import Quickshell.Io
import qs.commonwidgets
import qs.modules
import qs.modules.audio
import qs.theme as T
import qs.services as S
import qs.modules.overview as O

HoverPopupWindow {
    id: popup
    popupWidth: 700


    ColumnLayout {
        id: col
        Layout.bottomMargin: 20
        width: 500
        spacing: 14

        // ── Header ──────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 80
            radius: 18
            color: T.Config.bg1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // Avatar
                Rectangle {
                    width: 40
                    height: 40
                    radius: 999
                    color: T.Config.bg3
                    Layout.alignment: Qt.AlignVCenter

                    // Replace with your avatar image
                    Text {
                        anchors.centerIn: parent
                        text: "B"
                        color: T.Config.fg
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Brian"
                        color: T.Config.fg
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "up 7 hours, 47 minutes" // plug your uptime here
                        color: "#ffffffaa"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                O.SystemOptions{}

            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 18
                color: "transparent"

                AudioVolumeSlider{
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 40
                radius: 18
                color: "#151320"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: ""
                        width: 16; height: 16
                        color: "white"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Slider {
                        Layout.fillWidth: true
                        value: 0.7
                    }
                }
            }
        }

        
      WifiNetworkPanel {
        id: wifiNetworkPanel
        trigger: wifiCard
      }


        // ── Grid of cards ────────────────────────
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10

            // Wi-Fi
            ControlCard {
                id: wifiCard
                title: "Wifi"
                visible: S.Network.wifiDevice && !S.Network.ethernetConnected
                subtitle: S.Network.ssid
                accent: true
                iconSource: S.Network.wifiConnected ? "󰤨" :  "󰤭" 
                Layout.fillWidth: true
                connectedOverview: overviewWifi
                onClicked: {
                    S.PopupManager.closeOthers(overviewWifi)
                    overviewWifi.visible = true
                }
            }
            
            ControlCard {
                id: ethernetCard
                title: "Ethernet"
                visible: S.Network.ethernetDevice && S.Network.wifiConnected
                subtitle: S.Network.ethernetConnected ? S.Network.ethernetConnectedIP : "Disconnected"
                accent: true
                iconSource: "󰌗"
                Layout.fillWidth: true
                connectedOverview: overviewWifi
                onClicked: {
                    S.PopupManager.closeOthers(overviewWifi)
                    overviewWifi.visible = true
                }
            }


            // Bluetooth
            ControlCard {
                title: "Bluetooth"
                subtitle: S.Bluetooth.connected ? "Connected Devices" : "No Devices"
                accent: true
                iconSource: "󰂯"
                Layout.fillWidth: true
                connectedOverview: overviewBluetooth
                onClicked: {
                    S.PopupManager.closeOthers(overviewBluetooth)
                    overviewBluetooth.visible = true
                }
            }

            // Speaker
            ControlCard {
                title: "Sound"
                subtitle: ""
                iconSource: ""
                Layout.fillWidth: true
                connectedOverview: overviewSound
                onClicked: {
                    S.PopupManager.closeOthers(overviewSound)
                    overviewSound.visible = true
                }

            }

            // // Mic
            // ControlCard {
            //     title: "Built-in Audio Analog St…"
            //     subtitle: "15%"
            //     iconSource: "audio-input-microphone-symbolic"
            //     Layout.fillWidth: true
            // }

            // // Battery
            // ControlCard {
            //     title: "Battery"
            //     subtitle: "100% • Charging"
            //     iconSource: "battery-full-symbolic"
            //     Layout.fillWidth: true
            // }
            //
            // // Disk
            // ControlCard {
            //     title: "/"
            //     subtitle: "80.0G / 186.7G (43%)"
            //     iconSource: "drive-harddisk-symbolic"
            //     Layout.fillWidth: true
            // }
            //
            // // Color picker
            // ControlCard {
            //     title: "Color Picker"
            //     subtitle: "Choose a color"
            //     iconSource: "preferences-desktop-color"
            //     Layout.fillWidth: true
            // }
            //
            // // Keep awake
            // ControlCard {
            //     title: "Keep Awake"
            //     subtitle: ""
            //     iconSource: "media-playback-pause-symbolic"
            //     Layout.fillWidth: true
            // }
            //
            // // Do not disturb
            // ControlCard {
            //     title: "Do Not Disturb"
            //     subtitle: ""
            //     iconSource: "notifications-disabled-symbolic"
            //     Layout.columnSpan: 2
            //     Layout.fillWidth: true
            // }
            //
            // // Bottom row icons (sleep / dark mode) – simple example
            // RowLayout {
            //     Layout.columnSpan: 2
            //     Layout.fillWidth: true
            //     spacing: 10
            //
            //     ControlCard {
            //         title: ""
            //         subtitle: ""
            //         iconSource: "media-playback-stop-symbolic"
            //         Layout.fillWidth: true
            //     }
            //     ControlCard {
            //         title: ""
            //         subtitle: ""
            //         iconSource: "weather-clear-night-symbolic"
            //         Layout.fillWidth: true
            //     }
            // }
        }
        ColumnLayout {
            Layout.fillWidth: true
            O.Wifi{
                id: overviewWifi
                visible: false
                Component.onCompleted: {
                    S.PopupManager.register(overviewWifi)
                }
            }
            O.Bluetooth{
                id: overviewBluetooth
                visible: false
                Component.onCompleted: {
                    S.PopupManager.register(overviewBluetooth)
                }
            }
            O.Sound{
                id: overviewSound
                visible: false
                Component.onCompleted: {
                    S.PopupManager.register(overviewSound)
                }
            }

        }
    }
}
