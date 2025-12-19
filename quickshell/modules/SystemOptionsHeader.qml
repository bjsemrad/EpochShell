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
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 30

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 30
        color: "transparent"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "System"
            color: T.Config.surfaceText
            font.bold: true
            font.pointSize: 13
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        Process {
            id: missionCenter
            command: ["flatpak", "run", "io.missioncenter.MissionCenter"]
        }

        PanelHeaderIcon {
            id: systemMonitorSettings
            iconText: "󰄧"
            function onClick() {
                missionCenter.running = true;
            }
        }

        Process {
            id: firmware
            command: ["gnome-firmware"]
        }

        PanelHeaderIcon {
            id: firmwareSettings
            iconText: ""
            function onClick() {
                firmware.running = true;
            }
        }
    }
}
