import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import qs.theme as T
import qs.services as S
import qs.commonwidgets

ConnectedNetwork {
    connectedStatus: S.Network.wifiConnected
    networkIconText: "󰤨"
    connectedName: S.Network.ssid
    connectedIp: S.Network.wifiConnectedIP
}
