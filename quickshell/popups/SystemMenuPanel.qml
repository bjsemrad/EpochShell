import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Io
import qs.commonwidgets
import qs.modules
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: systemMenuPopup
    trigger: trigger
    popupWidth: T.Config.systemPopupWidth

    property string username

    Process {
        id: whoami
        command: ["whoami"]
        running: true

        stdout: SplitParser {
            onRead: data => username = data.trim()
        }
    }

    Component.onDestruction: S.PopupManager.unregister(systemMenuPopup)
    Component.onCompleted: S.PopupManager.register(systemMenuPopup, "system")

    onVisibleChanged: {
        if (visible) {
            S.SystemInfo.refresh();
            S.PopupManager.closeOthers(systemMenuPopup);
        }
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "System"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "󱄅"
            color: T.Config.accent
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: systemMenuPopup.username
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // What this machine is. Three facts people look up and never remember: the model, the firmware
    // it is running, and the kernel. Laid out as label/value pairs so the values line up rather
    // than running together in a sentence.
    GridLayout {
        Layout.fillWidth: true
        Layout.topMargin: 2
        columns: 2
        columnSpacing: T.Config.layoutMarginSmall
        rowSpacing: 1
        visible: S.SystemInfo.machine.length > 0 || S.SystemInfo.kernel.length > 0

        Text {
            text: "model"
            visible: S.SystemInfo.machine.length > 0
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
        }
        Text {
            text: S.SystemInfo.machine
            visible: S.SystemInfo.machine.length > 0
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: "bios"
            visible: S.SystemInfo.biosVersion.length > 0
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
        }
        Text {
            text: S.SystemInfo.biosVersion
            visible: S.SystemInfo.biosVersion.length > 0
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: "kernel"
            visible: S.SystemInfo.kernel.length > 0
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
        }
        Text {
            text: S.SystemInfo.kernel
            visible: S.SystemInfo.kernel.length > 0
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    ComponentSplitter {}

    // Power actions
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Process {
            id: lock
            command: ["hyprlock"]
        }

        SystemAction {
            icon: "󰌾"
            description: "Lock"
            function onClick() {
                lock.running = true;
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
                sleep.running = true;
            }
        }

        Process {
            id: reboot
            command: ["systemctl", "reboot"]
        }

        SystemAction {
            icon: "󰜉"
            description: "Restart"
            function onClick() {
                reboot.running = true;
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
                poweroff.running = true;
            }
        }

        Process {
            id: logout
            command: ["sh", "/home/" + systemMenuPopup.username + "/.config/wmscripts/logout.sh"]
        }

        SystemAction {
            icon: "󰗽"
            description: "Logout"
            function onClick() {
                logout.running = true;
            }
        }
    }

    ComponentSpacer {
        bottomMargin: 6
    }
}
