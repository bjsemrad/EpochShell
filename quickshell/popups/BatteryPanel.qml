import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.modules.battery
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: batteryPopup
    trigger: trigger
    popupWidth: T.Config.batteryPopupWidth

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Battery"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    ComponentSplitter {}

    BatteryLevel{}

    ComponentSplitter {
        visible: S.PowerProfile.available
    }

    PowerProfileRow {}

    ComponentSplitter {
        visible: S.StayAwake.available
    }

    // Stay awake belongs with the battery: both answer "what is this laptop about to do to
    // itself". The lock is held by EpochOxide, so the switch reflects what is actually held rather
    // than what this panel last asked for.
    ToggleRow {
        label: "Stay awake"
        hint: S.StayAwake.enabled ? ("held for " + S.StayAwake.held) : "Prevent idle lock and sleep"
        checkedValue: S.StayAwake.enabled
        visible: S.StayAwake.available

        function handleToggled(checked) {
            S.StayAwake.set(checked);
        }
    }

    ComponentSpacer{ bottomMargin: 6 }

    // The CPU state changes constantly -- auto-cpufreq flips turbo as load moves -- so it is
    // re-read while this panel is on screen and left alone the rest of the time.
    onVisibleChanged: {
        S.PowerProfile.watching = visible;
        if (visible){
            // Ask on open rather than waiting for a poll: opening the panel is exactly the moment
            // someone wants the answer, and a row that appears a few seconds later reads as broken.
            S.PowerProfile.refresh()
            S.SystemInfo.refresh()
            S.StayAwake.refresh()
            S.PopupManager.closeOthers(batteryPopup)
        }
    }

    Component.onDestruction: S.PopupManager.unregister(batteryPopup)
    Component.onCompleted: {
        S.PopupManager.register(batteryPopup, "battery")
    }
}

