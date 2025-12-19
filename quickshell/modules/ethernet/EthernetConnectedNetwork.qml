import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.services as S
import qs.theme as T
import qs.commonwidgets

ConnectedNetwork {
    connectedStatus: S.Network.ethernetConnected
    networkIconText: "󰌗"
    connectedName: S.Network.ethernetDeviceName
    connectedIp: S.Network.ethernetConnectedIP
}
