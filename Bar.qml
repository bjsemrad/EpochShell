import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Io
import qs.theme as T
import qs.popups
import qs.modules
import qs.modules.audio
import qs.modules.battery
import qs.modules.bluetooth
import qs.modules.ethernet
import qs.modules.wifi
import qs.modules.tailscale
import qs.modules.systemtray
import qs.services as S

Scope {
  id: bar
  property string time

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
      color: T.Config.bg
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
        spacing: 0
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
            popup: wifiNetworkPanel
          },
          EthernetNetwork{
            id:ethNet
            popup: ethernetNetworkPanel
          },
          TailscaleNetwork {
            id:tailNet
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
          SystemTray{
            id: sysTray
            popup: systemTrayPanel
          },
          SystemOptions{
            id: systemOptions
            popup: systemOptionsPanel
          },
          SystemOptions{
            id: systemOverview
            popup: systemPanel
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
      SystemTrayPanel {
        id: systemTrayPanel
        trigger: sysTray
      }
      SystemPanel {
        id: systemPanel
        trigger: systemOverview
      }
    }
  }
}
