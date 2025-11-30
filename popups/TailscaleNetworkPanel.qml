import Quickshell
import Quickshell.Wayland        // for WlrLayershell + WlrLayer
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import "../commonwidgets"
import "../modules"
import "../theme" as T
import "../services" as S

HoverPopupWindow {
    id: tailscalePopup
    trigger: trigger
    
    function refresh() {
        S.NetworkMonitor.refresh()
    }

    // Timer {
    //     id: refreshTimer
    //     interval: 5000  
    //     repeat: true
    //     running: tailscalePopup.visible
    //
    //     onTriggered: {
    //         refresh()
    //     }
    // }
    //
    onVisibleChanged: {
        if (visible) {
            refresh()
            S.PopupManager.closeOthers(tailscalePopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(tailscalePopup)
    }

    Row {
        id: tailscaleContent
        spacing: 10
        Column {
            width: T.Config.tailscalePopupWidth
            spacing: 10
            TailscaleOnOff {}
            ComponentSplitter{}
            TailscaleConnectedNetwork{}
            ComponentSplitter{}
            TailscalePeers{}
            ComponentSpacer{}
        }
    }
}

