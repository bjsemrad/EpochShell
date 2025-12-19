import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import Quickshell.Io
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: container.implicitHeight
    Layout.bottomMargin: 10

    Rectangle {
        id: container
        anchors.fill: parent
        implicitHeight: content.implicitHeight
        color: "transparent"

        ColumnLayout {
            id: content
            spacing: 20
            width: parent.width * .55
            anchors.verticalCenter: parent.verticalCenter
            RowLayout {
                spacing: 10
                Layout.fillWidth: true
                Text {
                    text: S.BatteryService.batteryIcon()
                    color: T.Config.surfaceText
                    font.bold: true
                    font.pointSize: 12
                }

                Text {
                    text: Math.round(S.BatteryService.percentage) + "%"
                    color: T.Config.surfaceText
                    font.bold: true
                    font.pointSize: 12
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: S.BatteryService.stateText()
                    color: T.Config.surfaceText
                    font.bold: true
                    font.pointSize: 11
                }
            }
        }
    }
}
