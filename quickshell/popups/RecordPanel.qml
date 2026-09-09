import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.theme as T
import qs.services as S

// The recording drawer panel: pick what to record, or stop what is running.
//
// Recording gets its own panel rather than a section inside the capture one because it is the one
// capture with a state: the panel is a list of things to start, or -- while something is running
// -- the single thing worth doing. Mixing that into the screenshot panel would leave half of it
// inert whenever a recording was in progress.
HoverPopupWindow {
    id: recordPopup
    trigger: trigger
    popupWidth: T.Config.capturePopupWidth

    onVisibleChanged: {
        if (visible) {
            S.Capture.refresh();
            S.Capture.refreshRecording();
            S.PopupManager.closeOthers(recordPopup);
        }
    }

    Component.onDestruction: S.PopupManager.unregister(recordPopup)
    Component.onCompleted: S.PopupManager.register(recordPopup, "record")

    Process {
        id: openFolder
    }

    // Header
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Record"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "󰕧"
            color: S.Capture.recording ? T.Config.red : T.Config.accent
            font.pixelSize: T.Config.fontSizeLarge
            font.family: T.Config.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        Layout.fillWidth: true
        visible: text.length > 0
        text: {
            if (S.Capture.backendError.length > 0) return S.Capture.backendError;
            if (!S.Capture.recordAvailable) return "wf-recorder is not installed";
            if (S.Capture.recording) return "Recording " + S.Capture.recordingMode + " · " + S.Capture.recordingElapsed;
            return S.Capture.status;
        }
        color: (S.Capture.backendError.length > 0 || !S.Capture.recordAvailable) ? T.Config.red : T.Config.outline
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    ComponentSplitter {}

    // What to start. Hidden wholesale while something is running: only one recording runs at a
    // time, so offering four more would be offering four errors.
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: !S.Capture.recording && S.Capture.recordAvailable

        SystemAction {
            icon: "󰆞"
            description: "Region"
            function onClick() {
                S.Capture.startRecording("region", false);
            }
        }

        SystemAction {
            icon: "󰖯"
            description: "Focused window"
            visible: S.Capture.windowCapture
            Layout.preferredHeight: visible ? T.Config.systemActionSize : 0
            function onClick() {
                S.Capture.startRecording("window", false);
            }
        }

        SystemAction {
            icon: "󰆟"
            description: "Pick a window"
            visible: S.Capture.windowCapture
            Layout.preferredHeight: visible ? T.Config.systemActionSize : 0
            function onClick() {
                S.Capture.startRecording("window", true);
            }
        }

        SystemAction {
            icon: "󰍹"
            description: "This monitor"
            function onClick() {
                S.Capture.startRecording("fullscreen", false);
            }
        }

        SystemAction {
            icon: "󰍺"
            description: "All monitors"
            function onClick() {
                S.Capture.startRecording("all", false);
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: S.Capture.recording

        SystemAction {
            icon: "󰙧"
            description: "Stop recording · " + S.Capture.recordingElapsed
            function onClick() {
                S.Capture.stopRecording();
            }
        }
    }

    ComponentSplitter {}

    SystemAction {
        icon: "󰉋"
        description: "Open folder"
        function onClick() {
            if (S.Capture.recordingDirectory.length === 0) return;
            S.PopupManager.closeAll();
            openFolder.command = ["xdg-open", S.Capture.recordingDirectory];
            openFolder.running = true;
        }
    }

    ComponentSpacer { bottomMargin: 6; Layout.preferredHeight: 1 }
}
