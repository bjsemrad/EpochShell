import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import "../commonwidgets" as CW
import "../theme" as T
RowLayout {
    id: root

    property real percentage: 0
    property bool charging: false
    property string icon: ""
    property color color: (!charging && percentage < 20) ? "red" : "white"

    Component.onCompleted: {
        if (UPower.displayDevice) {
            percentage = UPower.displayDevice.percentage
            charging   = (UPower.displayDevice.state === UPowerDeviceState.Charging)
            icon   = iconForBattery()
        }
    }

    Connections {
        target: UPower.displayDevice

        function onPercentageChanged() {
            root.percentage = UPower.displayDevice.percentage
            root.icon = iconForBattery()
        }

        function onStateChanged() {
            root.charging = (UPower.displayDevice.state === UPowerDeviceState.Charging)
            root.icon = iconForBattery()
        }
    }

    function iconForBattery() {
      let pct = Math.round(root.percentage > 0 ? root.percentage * 100 : 1)
      if (pct > 95) return root.charging ? "󰂋" : "󰁹"
      if (pct > 70) return root.charging ? "󰢞" : "󰂀"
      if (pct > 45) return root.charging ? "󰂈" : "󰁽"
      if (pct > 20) return root.charging ? "󰂆" : "󰁻"
      if (pct > 5)  return root.charging ? "󰢜" : "󰁺"
    }

    Text {
        text:root.icon
        font.pixelSize: 18
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        width: 20
        color: T.Config.fg
    }


    // IconImage {
    //     implicitSize: 16
    //     anchors.verticalCenter: parent.verticalCenter
    //     source: Quickshell.iconPath(root.iconName)
    // }

    // Text {
    //     text: `${Math.round(percentage)}%`
    //     color: root.color
    //     font.pixelSize: 12
    // }
}


// import QtQuick
// import QtQuick.Layouts
// import Quickshell
// import Quickshell.Widgets
// import Quickshell.Services.UPower
// import "../commonwidgets" as CW
//
// RowLayout {
//   id: root
//   property real percentage: UPower.displayDevice.percentage
//   property real charging: UPower.displayDevice.state === UPowerDeviceState.Charging
//   property color color: (!charging && percentage * 100 < 20) ? "red" : "white"
//   spacing: 0
//
//   // Build icon name
//     function iconForBattery() {
//         if (!root) return "battery-missing-symbolic"
//
//         let pct = Math.round(root.percentage ?? 0)
//
//         function icon(level) {
//             return charging
//                 ? `battery-level-${level}-charging-symbolic`
//                 : `battery-level-${level}-symbolic`
//         }
//
//         if (pct >= 95) return icon(100)
//         if (pct >= 80) return icon(90)
//         if (pct >= 60) return icon(70)
//         if (pct >= 40) return icon(50)
//         if (pct >= 20) return icon(30)
//         return icon(10)
//       }
//
//    IconImage {
//         // anchors.centerIn: parent
//         implicitSize: 16
//         source: Quickshell.iconPath(iconForBattery())
//       }
//
//    Connections {
//     target: UPower.displayDevice
//
//     function onPercentageChanged() {
//         root.percentage = UPower.displayDevice.percentage
//     }
//
//     function onStateChanged() {
//         root.charging = (UPower.displayDevice.state === UPowerDeviceState.Charging)
//     }
// }
//
//

  // CW.FontIcon {
  //   Layout.alignment: Qt.AlignVCenter
  //   color: root.color
  //   iconSize: 15
  //   text: {
  //     const iconNumber = Math.round(root.percentage * 7);
  //     return root.charging ? "battery_android_bolt" : `battery_android_${iconNumber >= 7 ? "full" : iconNumber}`;
  //   }
  // }

  // CW.StyledText {
  //   Layout.alignment: Qt.AlignVCenter
  //   Layout.fillHeight: true
  //   Layout.leftMargin: 10
  //   text: `${Math.round(percentage * 100)}%`
  //   color: root.color
  // }
// }
