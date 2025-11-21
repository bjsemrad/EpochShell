import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Io
import "./theme" as T
import "./popups"
import "./components"
import "./modules"

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

        children: [Workspaces{}]
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
          Network{
            id:net
            popup: controlPanel
          }, 
          Battery{}, 
          TrayWidget{}, 
          BarFill{} ] 
      }

      // NetworkPopup {
      //   id: netPopup
      //   screen: barWindow.screen
      // }

      ControlPanel {
        id: controlPanel
        trigger: net
      }
    }
  }
}
