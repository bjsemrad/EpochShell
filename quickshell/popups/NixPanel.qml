import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.modules.nix
import qs.theme as T
import qs.services as S

// The flake update panel: what is pinned, what could move, and the two commands that act on it.
//
// Nothing here changes a system on its own. "Update" and each host's "Rebuild" open a terminal
// running a command the user configured, so what happens next is visible and interruptible rather
// than a silent rebuild started by a panel.
HoverPopupWindow {
    id: nixPopup
    trigger: trigger
    popupWidth: T.Config.nixPopupWidth

    onVisibleChanged: {
        if (visible) {
            S.NixUpdates.refresh();
            S.PopupManager.closeOthers(nixPopup);
        }
    }

    Component.onDestruction: S.PopupManager.unregister(nixPopup)
    Component.onCompleted: S.PopupManager.register(nixPopup, "nix")

    // Header
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Nix"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: S.NixUpdates.icon
            color: S.NixUpdates.hasUpdates ? T.Config.accent : T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.family: T.Config.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        Layout.fillWidth: true
        visible: text.length > 0
        text: {
            if (S.NixUpdates.backendError.length > 0) return S.NixUpdates.backendError;
            if (!S.NixUpdates.configured) return "No flake configured (set nix_flake)";
            if (!S.NixUpdates.available) return S.NixUpdates.reason;
            if (S.NixUpdates.error.length > 0) return S.NixUpdates.error;
            return S.NixUpdates.flake;
        }
        color: (S.NixUpdates.backendError.length > 0 || !S.NixUpdates.available || S.NixUpdates.error.length > 0) ? T.Config.red : T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    Text {
        Layout.fillWidth: true
        visible: S.NixUpdates.available
        text: {
            if (S.NixUpdates.checking) return "Checking every input...";
            if (S.NixUpdates.status.length > 0) return S.NixUpdates.status;
            if (S.NixUpdates.checkedAt === 0) return "Not checked yet";
            const updates = S.NixUpdates.updates === 0
                ? "Everything is current"
                : (S.NixUpdates.updates === 1 ? "1 input can be updated" : S.NixUpdates.updates + " inputs can be updated");
            return updates + " · checked " + S.NixUpdates.ago(S.NixUpdates.checkedAt) + " ago";
        }
        color: T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    Text {
        Layout.fillWidth: true
        visible: S.NixUpdates.available && S.NixUpdates.lockedAt > 0
        text: "Locked " + S.NixUpdates.ago(S.NixUpdates.lockedAt) + " ago"
        color: T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    ComponentSplitter {
        visible: S.NixUpdates.movable.length > 0
        Layout.preferredHeight: visible ? undefined : 0
    }

    // What could move. Inputs that are already current are left out: a wall of unchanged names
    // buries the answer the panel exists to give.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        visible: S.NixUpdates.movable.length > 0

        Repeater {
            model: S.NixUpdates.movable

            delegate: NixInput {
                required property var modelData
                name: String(modelData.name || "")
                source: String(modelData.source || "")
                currentRev: String(modelData.current_rev || "")
                latestRev: String(modelData.latest_rev || "")
            }
        }
    }

    ComponentSplitter {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        SystemAction {
            icon: "󰑐"
            description: S.NixUpdates.checking ? "Checking..." : "Check for updates"
            function onClick() {
                S.NixUpdates.check();
            }
        }

        SystemAction {
            icon: "󰚰"
            description: "Update flake"
            visible: S.NixUpdates.updateCommand.length > 0
            Layout.preferredHeight: visible ? T.Config.systemActionSize : 0
            function onClick() {
                S.PopupManager.closeAll();
                S.NixUpdates.update();
            }
        }
    }

    ComponentSplitter {
        visible: nixPopup.rebuildable.length > 0
        Layout.preferredHeight: visible ? undefined : 0
    }

    // Every host in the flake shares one lock, so there is nothing per-host to report about
    // updates. What is per host is the command that rebuilds it, which is why they appear here
    // and not next to the inputs. A host with no configured command is left out rather than
    // offered as a button that cannot do anything.
    readonly property var rebuildable: S.NixUpdates.hosts.filter(host => String(host.rebuild || "").length > 0)

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: nixPopup.rebuildable.length > 0

        Repeater {
            model: nixPopup.rebuildable

            delegate: SystemAction {
                required property var modelData
                icon: "󰇷"
                description: "Rebuild " + String(modelData.name || "")
                function onClick() {
                    S.PopupManager.closeAll();
                    S.NixUpdates.rebuild(String(modelData.name || ""));
                }
            }
        }
    }

    ComponentSpacer { bottomMargin: 6; Layout.preferredHeight: 1 }
}
