import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules
import qs.modules.audio
import qs.modules.battery
import qs.modules.bluetooth
import qs.modules.ethernet
import qs.modules.systemtray
import qs.modules.tailscale
import qs.modules.wifi
import qs.popups
import qs.theme as T

RowLayout {
    spacing: 0
    BarFill {}
    WifiNetwork {
        id: wifiNet
        popup: wifiNetworkPanel
    }
    EthernetNetwork {
        id: ethNet
        popup: ethernetNetworkPanel
    }
    // TailscaleNetwork {
    //     id: tailNet
    //     popup: tailscaleNetworkPanel
    // }
    Bluetooth {
        id: bluet
        popup: bluetoothPanel
    }
    Volume {
        id: vol
        popup: audioPanel
    }
    Battery {
        id: battery
        popup: batteryPanel
    }
    SystemOptions {
        id: systemOptions
        popup: T.Config.popupControlCenter ? systemPanelPopup : systemPanel
    }
    BarFill {}

    WifiNetworkPanel {
        id: wifiNetworkPanel
        trigger: wifiNet
    }

    EthernetNetworkPanel {
        id: ethernetNetworkPanel
        trigger: ethNet
    }

    // TailscaleNetworkPanel {
    //     id: tailscaleNetworkPanel
    //     trigger: tailNet
    // }

    AudioPanel {
        id: audioPanel
        trigger: vol
    }

    BatteryPanel {
        id: batteryPanel
        trigger: battery
    }

    BluetoothPanel {
        id: bluetoothPanel
        trigger: bluet
    }
    ControlCenterPanelPopup {
        id: systemPanelPopup
        trigger: systemOptions
    }
    ControlCenterPanel {
        id: systemPanel
        trigger: systemOptions
    }
    Clock {}
}
