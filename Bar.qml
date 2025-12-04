import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Io
import "./theme" as T
import "./popups"
import "./modules"
import "./services" as S

Scope {
  id: bar
  property string time

  // NetworkMonitor {
    // id: netMon
  // }
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: barWindow
      required property var modelData
      screen: modelData
      WlrLayershell.layer: WlrLayer.Top
      anchors {
        top: true
        left: true
        right: true
      }
      color: "black"       // ← BLACK PANEL

      implicitHeight: 40

      RowLayout {
        id: leftSide
        spacing: 10
        anchors {
          top: parent.top
          bottom: parent.bottom
          left: parent.left
        }

        children: [
          BarFill{},
          ApplicationLauncher{},
          Workspaces{}
        ]
      }

       RowLayout {
         id: centerSide
         spacing: 10

         anchors {
            top: parent.top
            bottom: parent.bottom
          }
          readonly property int available: parent.width

          implicitWidth: available
          children: [BarFill{}, Clock{}, BarFill{}]
      }

      RowLayout {
        id: rightSide
        spacing: 10
        Layout.alignment: Qt.AlignVCenter

        anchors {
          top: parent.top
          bottom: parent.bottom
          right: parent.right
        }

        children: [
          BarFill{},
          WifiNetwork{
            id:wifiNet
            visible: S.Network.wifiDevice && !S.Network.ethernetConnected
            popup: wifiNetworkPanel
          },
          EthernetNetwork{
            id:ethNet
            visible: S.Network.ethernetDevice && !S.Network.wifiConnected
            popup: ethernetNetworkPanel
          },
          TailscaleNetwork {
            id:tailNet
            visible: S.Network.tailscaleConnected
            popup: tailscaleNetworkPanel
          },
          Bluetooth{
            id:bluet
            popup: bluetoothPanel
          },
          Volume {
            id: vol
            popup: audioPanel
          },
          Battery{
            id: battery
            popup: batteryPanel
          },
          Clipboard{},
          Colorpicker{},
          // TrayWidget{}, 
          SystemOptions{
            id: systemOptions
            popup: systemOptionsPanel
          },
          BarFill{} ] 
      }

      WifiNetworkPanel {
        id: wifiNetworkPanel
        trigger: wifiNet
      }

      EthernetNetworkPanel {
        id: ethernetNetworkPanel
        trigger: ethNet
      }

      TailscaleNetworkPanel {
        id: tailscaleNetworkPanel
        trigger: tailNet
      }

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
      SystemOptionsPanel {
        id: systemOptionsPanel
        trigger: systemOptions
      }
    }
  }
}
