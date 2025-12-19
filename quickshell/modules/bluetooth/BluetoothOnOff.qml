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
    headerText: "Bluetooth"
    enableToggle: true
    checkedValue: true

    function settingsClick(){
        S.Bluetooth.settings()
    }

    function handleToggled(checked){
       S.Bluetooth.toggle(checked)
    }
}
