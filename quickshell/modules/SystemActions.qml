import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.services as S
import qs.theme as T
import qs.commonwidgets

Item {
    id: systemOptionsSection
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight

    property bool expanded: false

    ColumnLayout {
        id:contents
        anchors.margins: 4
        anchors.fill: parent
        spacing: 10

        Process {
            id: lock
            command: ["hyprlock"]
        }

        SystemAction {
            icon: ""
            description: "Lock"
            function onClick() {
                lock.running = true
            }
        }

        Process {
            id: sleep
            command: ["systemctl", "suspend"]
        }

        SystemAction {
            icon: "󰤄"
            description: "Sleep"
            function onClick() {
                sleep.running = true
            }
        }

        Process {
            id: reboot
            command: ["systemctl", "reboot"]
        }


        SystemAction {
            icon: ""
            description: "Reboot"
            function onClick() {
                reboot.running = true
            }
        }

        Process {
            id: poweroff
            command: ["systemctl", "poweroff"]
        }

        SystemAction {
            icon: "⏻"
            description: "Shutdown"
            function onClick() {
                poweroff.running = true
            }
        }

        Process {
            id: logout
            command: ["sh", "~/.config/wmscripts/logout.sh"]
        }

        SystemAction {
            icon: "󰗽"
            description: "Logout"
            function onClick() {
                logout.running = true
            }
        }

    }
}
