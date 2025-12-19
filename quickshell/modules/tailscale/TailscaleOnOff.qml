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
    headerText: "Tailscale"
    checkedValue: S.Tailscale.connected

    function handleToggled(checked){
        S.Tailscale.toggle(checked)
    }

    function settingsClick(){
        S.Tailscale.trayscale()
    }
}
