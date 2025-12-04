import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import Quickshell.Io
import "../theme" as T
import "../services" as S
import "../commonwidgets"

import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: parent.width
    height: 60
    radius: 40
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        color: "transparent"

        Column {
            spacing: 20
            width: parent.width*.55
            anchors.verticalCenter: parent.verticalCenter
            Row {
                spacing: 10
                width: parent.width
                Text {
                    text: S.BatteryService.batteryIcon()
                    color: T.Config.fg
                    font.bold: true
                    font.pointSize: 13
                }

                Text {
                    text: S.BatteryService.percentage + "%"
                    color: T.Config.fg
                    font.bold: true
                    font.pointSize: 13
                }
            }

             Row {
                spacing: 10
                width: parent.width
                Text {
                    text: S.BatteryService.stateText()
                    color: T.Config.fg
                    font.bold: true
                    font.pointSize: 11
                }

            }

        }
    }
  }
