import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.modules.capture
import qs.theme as T
import qs.services as S

// The capture drawer panel: pick what to photograph, and say what should happen to it.
//
// Every action closes the panel on its way out. A screenshot of the screenshot panel is not a
// screenshot anyone wanted, and the delay that covers the compositor's next frame is applied in
// the Capture service rather than here.
HoverPopupWindow {
    id: capturePopup
    trigger: trigger
    popupWidth: T.Config.capturePopupWidth

    // Where shots land and whether this compositor can hand over a window rectangle can both
    // change under a running shell -- a compositor restart is enough -- so they are asked for
    // when the panel opens rather than once at startup.
    onVisibleChanged: {
        if (visible) {
            S.Capture.refresh();
            S.PopupManager.closeOthers(capturePopup);
        }
    }

    Component.onDestruction: S.PopupManager.unregister(capturePopup)
    Component.onCompleted: S.PopupManager.register(capturePopup, "capture")

    Process {
        id: openFolder
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Capture"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: S.Capture.icon
            color: T.Config.accent
            font.pixelSize: T.Config.fontSizeLarge
            font.family: T.Config.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // What just happened, or what is stopping it from happening.
    Text {
        Layout.fillWidth: true
        visible: text.length > 0
        text: {
            if (S.Capture.backendError.length > 0) return S.Capture.backendError;
            if (!S.Capture.available && S.Capture.unavailableReason.length > 0) return S.Capture.unavailableReason;
            if (S.Capture.status.length > 0) return S.Capture.status;
            // Rows that hide themselves leave no trace, so the one thing missing is named here.
            if (!S.Capture.ocrAvailable) return "tesseract is not installed, so text capture is off";
            return "";
        }
        color: (S.Capture.backendError.length > 0 || !S.Capture.available) ? T.Config.red : T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
        Layout.rightMargin: T.Config.systemActionSpacing
    }

    ComponentSplitter {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        SystemAction {
            icon: "󰆞"
            description: "Region"
            function onClick() {
                S.Capture.shoot("region", false);
            }
        }

        SystemAction {
            icon: "󰖯"
            description: "Focused window"
            visible: S.Capture.windowCapture
            function onClick() {
                S.Capture.shoot("window", false);
            }
        }

        SystemAction {
            icon: "󰆟"
            description: "Pick a window"
            visible: S.Capture.windowCapture
            function onClick() {
                S.Capture.shoot("window", true);
            }
        }

        SystemAction {
            icon: "󰍹"
            description: "This monitor"
            function onClick() {
                S.Capture.shoot("fullscreen", false);
            }
        }

        SystemAction {
            icon: "󰍺"
            description: "All monitors"
            function onClick() {
                S.Capture.shoot("all", false);
            }
        }

        // Reading text is a capture like the others, so it sits with them rather than in a
        // section of its own. It needs tesseract, which the status query reports on.
        SystemAction {
            icon: "󰈙"
            description: "Text from region"
            visible: S.Capture.ocrAvailable
            function onClick() {
                S.Capture.readText("region", false);
            }
        }
    }

    ComponentSplitter {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        CaptureOption {
            label: "Copy to clipboard"
            checkedValue: S.Capture.copyToClipboard
            function handleToggled(checked) {
                S.Capture.setCopyToClipboard(checked);
            }
        }

        CaptureOption {
            label: "Save to file"
            hint: S.Capture.directory
            checkedValue: S.Capture.saveToDisk
            function handleToggled(checked) {
                S.Capture.setSaveToDisk(checked);
            }
        }

        CaptureOption {
            label: "Include pointer"
            checkedValue: S.Capture.includeCursor
            function handleToggled(checked) {
                S.Capture.setIncludeCursor(checked);
            }
        }
    }

    ComponentSplitter {}

    SystemAction {
        icon: "󰉋"
        description: "Open folder"
        function onClick() {
            if (S.Capture.directory.length === 0) return;
            S.PopupManager.closeAll();
            openFolder.command = ["xdg-open", S.Capture.directory];
            openFolder.running = true;
        }
    }

    ComponentSpacer { bottomMargin: 6; Layout.preferredHeight: 1 }
}
