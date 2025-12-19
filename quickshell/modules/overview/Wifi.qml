import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules.wifi
import qs.commonwidgets
import qs.theme as T

ExpandingOverview {
    WifiOnOff {}
    ComponentSplitter {}
    WifiConnectedNetwork {}
    ComponentSplitter {}
    WifiSavedNetworks {}
    ComponentSplitter {}
    WifiAvailableNetworks {
        attachedPanel: parent
        bgColor: T.Config.surface
        clip: true
    }
    ComponentSpacer {}
}
