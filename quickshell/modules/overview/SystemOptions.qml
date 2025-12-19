import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.commonwidgets
import qs.modules.controlcenter

RowLayout {
    Layout.alignment: Qt.AlignRight
    spacing: 10

    Process {
        id: lock
        command: ["hyprlock"]
    }

    SystemActionIcon {
        icon: ""
        description: "Lock"
        function onClick() {
            lock.running = true;
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
            sleep.running = true;
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
            reboot.running = true;
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
            poweroff.running = true;
        }
    }

    property string username
    Process {
        id: whoami
        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: data => username = data.trim()
        }
    }

    Component.onCompleted: {
        if (!username) {
            whoami.running = true;
        }
    }

    Process {
        id: logout
        command: ["sh", "/home/" + username + "/.config/wmscripts/logout.sh"]
    }

    SystemActionIcon {
        icon: "󰗽"
        description: "Logout"
        function onClick() {
            logout.running = true;
        }
    }
}
