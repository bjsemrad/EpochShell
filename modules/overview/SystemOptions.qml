import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.commonwidgets

RowLayout {
    Layout.alignment:  Qt.AlignRight
    spacing: 10

    Process {
        id: lock
        command: ["hyprlock"]
    }

    SystemActionIcon {
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

    SystemActionIcon {
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


    SystemActionIcon {
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

    SystemActionIcon {
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

    SystemActionIcon {
        icon: "󰗽"
        description: "Logout"
        function onClick() {
            logout.running = true
        }
    }

}
