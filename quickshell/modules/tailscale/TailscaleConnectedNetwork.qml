import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import qs.services as S
import qs.theme as T
import qs.commonwidgets

ConnectedNetwork {
    connectedStatus: S.Tailscale.connected
    networkIconText: "󰒄"
    connectedName: S.Tailscale.magicDNSSuffix
    connectedIp: S.Network.tailscaleConnectedIP 
}
