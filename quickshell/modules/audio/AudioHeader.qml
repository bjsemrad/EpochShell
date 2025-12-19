import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.theme as T
import qs.commonwidgets
import qs.services as S


SettingsToggleHeader {
    headerText: "Sound"
    enableToggle: false
    checkedValue: false

    function settingsClick(){
        S.AudioService.openSettings()
    }
}
