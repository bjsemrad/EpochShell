import qs.commonwidgets
import qs.services as S

// Bar entry for LocalSend. Present whenever the backend is reachable, since a transfer is
// something the user initiates rather than a state to indicate.
BarIconPopup {
    id: root
    visible: S.LocalSend.connected
    mouseEnabled: true
    hoverEnabled: false
    iconText: S.LocalSend.sendingFile ? "󰔟" : S.LocalSend.icon
}
