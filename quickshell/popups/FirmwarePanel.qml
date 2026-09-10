import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.theme as T
import qs.services as S

// Firmware waiting to be installed.
//
// The panel lists what fwupd is offering and hands the job to fwupd: "Install updates" opens
// `fwupdmgr update` in a terminal, because it asks for a password, prints what it is about to
// write, and often ends by asking for a reboot. A shell panel is the wrong place for any of that.
HoverPopupWindow {
    id: firmwarePopup
    trigger: trigger
    popupWidth: T.Config.nixPopupWidth

    onVisibleChanged: {
        if (visible) {
            S.SystemInfo.refreshFirmware(false);
            S.PopupManager.closeOthers(firmwarePopup);
        }
    }

    Component.onDestruction: S.PopupManager.unregister(firmwarePopup)
    Component.onCompleted: S.PopupManager.register(firmwarePopup, "firmware")

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Firmware"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: S.SystemInfo.firmwareIcon
            color: S.SystemInfo.hasFirmwareUpdates ? T.Config.accent : T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.family: T.Config.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.rightMargin: T.Config.systemActionSpacing
        text: {
            const count = S.SystemInfo.firmwareUpdates.length;
            if (!S.SystemInfo.firmwareAvailable) return "fwupd is not available";
            if (count === 0) return "Everything is up to date";
            return count === 1 ? "1 update waiting" : (count + " updates waiting");
        }
        color: T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    ComponentSplitter {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: S.SystemInfo.firmwareUpdates

            delegate: Item {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: row.implicitHeight + 4

                ColumnLayout {
                    id: row
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: T.Config.systemActionSpacing
                    anchors.rightMargin: T.Config.systemActionSpacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: String(modelData.name || "")
                        color: T.Config.surfaceText
                        font.pixelSize: T.Config.fontSizeNormal
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: String(modelData.current || "?") + " → " + String(modelData.available || "?")
                        color: T.Config.outline
                        font.pixelSize: T.Config.fontSizeSubtext
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    ComponentSplitter {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        SystemAction {
            icon: "󰑐"
            description: "Check again"
            function onClick() {
                S.SystemInfo.refreshFirmware(true);
            }
        }

        SystemAction {
            icon: "󰚰"
            description: "Install updates"
            visible: S.SystemInfo.hasFirmwareUpdates
            function onClick() {
                S.PopupManager.closeAll();
                S.SystemInfo.updateFirmware();
            }
        }
    }

    ComponentSpacer { bottomMargin: 6; Layout.preferredHeight: 1 }
}
