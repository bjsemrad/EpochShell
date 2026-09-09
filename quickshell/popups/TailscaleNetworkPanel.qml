import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.modules.tailscale
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: tailscalePopup
    trigger: trigger
    popupWidth: T.Config.tailscalePopupWidth

    function refresh() {
        S.Tailscale.refresh()
    }

    onVisibleChanged: {
        if (visible) {
            refresh()
            S.PopupManager.closeOthers(tailscalePopup)
        }
    }

    Component.onDestruction: S.PopupManager.unregister(tailscalePopup)
    Component.onCompleted: {
        S.PopupManager.register(tailscalePopup, "tailscale")
    }

    TailscaleOnOff {}
    ComponentSplitter{}
    TailscaleConnectedNetwork{}
    ComponentSplitter{}
    TailscaleFileDrop{ popupWindow: tailscalePopup }
    ComponentSplitter{}
    TailscaleReceive{ popupWindow: tailscalePopup }
    ComponentSplitter{}
    TailscalePeers{}
    ComponentSpacer{ bottomMargin: 6; Layout.preferredHeight: 1 }
}
