import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.wifi
import qs.commonwidgets
ColumnLayout {
    Layout.fillWidth: true
    WifiOnOff {}
    ComponentSplitter{}
    WifiConnectedNetwork{}
    ComponentSplitter{}
    WifiSavedNetworks{}
    ComponentSplitter{}
    WifiAvailableNetworks{}
    ComponentSpacer{}
}
