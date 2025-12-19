import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.tailscale
import qs.commonwidgets
import qs.theme as T

ExpandingOverview {
    TailscaleOnOff {}
    ComponentSplitter {}
    TailscaleConnectedNetwork {}
    ComponentSplitter {}
    TailscalePeers {}
    ComponentSpacer {}
}
