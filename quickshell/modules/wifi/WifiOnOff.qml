import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.theme as T
import qs.services as S
import qs.commonwidgets

SettingsToggleHeader {
    headerText: "Wifi"
    enableToggle: true
    checkedValue: S.Network.wifiConnected

    function settingsClick() {
        S.Network.editNetworks();
    }

    function handleToggled(checked) {
        S.Network.disableWifi(checked);
    }
}
