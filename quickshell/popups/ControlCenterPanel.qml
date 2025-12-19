import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Greetd
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.commonwidgets
import qs.modules
import qs.modules.audio
import qs.theme as T
import qs.services as S
import qs.modules.overview as O

PanelWindow {
    id: popup
    implicitWidth: 600
    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    visible: true

    property var anim_CURVE_SMOOTH_SLIDE: [0.23, 1, 0.32, 1, 1, 1]
    property var trigger
    property bool open: false
    property bool stopHide: false
    property string username
    property var cards: []

    function showPanel() {
        open = true;
        for (let card of cards) {
            card.closeCard();
        }
        if (!T.Config.panelAnimationsEnabled) {
            visible = true;
        }
    }
    function hidePanel() {
        open = false;
        if (!T.Config.panelAnimationsEnabled) {
            visible = false;
        }
    }

    anchors {
        right: true
        top: true
        bottom: true
    }

    margins.right: !T.Config.panelAnimationsEnabled ? 0 : open ? 0 : -implicitWidth
    margins.top: T.Config.barHeight

    HoverHandler {
        onHoveredChanged: {
            if (!stopHide) {
                if (!hovered) {
                    hidePanel();
                }
            }
        }
    }

    Behavior on margins.right {
        enabled: T.Config.panelAnimationsEnabled
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        if (!username) {
            whoami.running = true;
        }
        S.PopupManager.register(popup);
        hidePanel();
    }

    onOpenChanged: {
        if (open) {
            S.PopupManager.closeOthers(popup);
        } else {
            for (let card of cards) {
                card.visible = false;
                card.resetCard();
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(popup);
        }
    }

    function registerCard(card) {
        if (cards.indexOf(card) === -1)
            cards.push(card);
    }

    function swapToCard(newCard) {
        if (newCard.expanded) {
            newCard.closeCard();
        } else {
            for (let card of cards) {
                if (card === newCard) {
                    card.openCard();
                } else {
                    card.closeCard();
                }
            }
        }
    }

    Process {
        id: whoami
        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: data => username = data.trim()
        }
    }

    SystemClock {
        id: sysclk
        precision: SystemClock.Seconds
    }

    ClippingRectangle {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.fill: parent
        color: T.Config.background

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: col.implicitHeight
            clip: true

            ColumnLayout {
                id: col
                anchors {
                    fill: parent
                    margins: 16
                }
                spacing: 20

                // ── Header card ───────────────────────────
                O.User {}

                O.UtilsSystemTray {
                    panelRef: popup
                }

                ColumnLayout {
                    id: tabwrapper
                    height: grid.implictHeight + cardContent.implicitHeight
                    spacing: 0

                    // ── Cards grid ────────────────────────────
                    GridLayout {
                        id: grid
                        Layout.fillWidth: true
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10

                        ControlCard {
                            id: wifiCard
                            title: "Wifi"
                            visible: S.Network.wifiDevice && !S.Network.ethernetConnected
                            subtitle: S.Network.ssid
                            accent: true
                            iconSource: S.Network.currentWifiIcon
                            Layout.fillWidth: true
                            connectedOverview: overviewWifi
                            onClicked: swapToCard(overviewWifi)
                        }

                        ControlCard {
                            id: ethernetCard
                            title: "Ethernet"
                            visible: S.Network.ethernetDevice && !S.Network.wifiConnected
                            subtitle: S.Network.ethernetConnected ? S.Network.ethernetConnectedIP : "Disconnected"
                            accent: true
                            iconSource: S.Network.currentEthernetIcon
                            Layout.fillWidth: true
                            connectedOverview: overviewEthernet
                            onClicked: swapToCard(overviewEthernet)
                        }

                        ControlCard {
                            title: "Bluetooth"
                            subtitle: S.Bluetooth.connected ? "Connected Devices" : "No Devices"
                            accent: true
                            iconSource: S.Bluetooth.currentBluetoothIcon
                            Layout.fillWidth: true
                            connectedOverview: overviewBluetooth
                            onClicked: swapToCard(overviewBluetooth)
                        }

                        ControlCard {
                            title: "Sound"
                            subtitle: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink?.description : "None"
                            iconSource: S.AudioService.currentAudioIcon
                            Layout.fillWidth: true
                            connectedOverview: overviewSound
                            onClicked: swapToCard(overviewSound)
                        }

                        ControlCard {
                            title: "Tailscale"
                            subtitle: S.Tailscale.connected ? S.Tailscale.magicDNSSuffix : "Disconnected"
                            iconSource: S.Tailscale.currentTailscaleIcon
                            Layout.fillWidth: true
                            connectedOverview: overviewTailscale
                            onClicked: swapToCard(overviewTailscale)
                        }
                    }
                    Rectangle {
                        id: cardContent
                        Layout.fillWidth: true
                        Layout.preferredHeight: cardStack.implicitHeight + 5
                        color: "transparent"

                        ColumnLayout {
                            id: cardStack
                            anchors.fill: parent
                            spacing: 0
                            O.Wifi {
                                id: overviewWifi
                                visible: false
                                animationEnabled: T.Config.panelAnimationsEnabled
                                Component.onCompleted: registerCard(overviewWifi)
                            }
                            O.Bluetooth {
                                id: overviewBluetooth
                                visible: false
                                animationEnabled: T.Config.panelAnimationsEnabled
                                Component.onCompleted: registerCard(overviewBluetooth)
                            }
                            O.Sound {
                                id: overviewSound
                                visible: false
                                animationEnabled: T.Config.panelAnimationsEnabled
                                Component.onCompleted: registerCard(overviewSound)
                            }
                            O.Tailscale {
                                id: overviewTailscale
                                visible: false
                                animationEnabled: T.Config.panelAnimationsEnabled
                                Component.onCompleted: registerCard(overviewTailscale)
                            }
                            O.Ethernet {
                                id: overviewEthernet
                                visible: false
                                animationEnabled: T.Config.panelAnimationsEnabled
                                Component.onCompleted: registerCard(overviewEthernet)
                            }
                        }
                    }
                }
                BarFill {}
                O.Stats {
                    Layout.fillWidth: true
                    container: popup
                }
            }
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                opacity: flick.moving ? 1 : 0.0

                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: T.Config.surfaceText
                }
            }
        }
    }
}
