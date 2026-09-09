import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry for LocalSend. Present whenever the backend is reachable, since a transfer is
// something the user initiates rather than a state to indicate.
BarIconPopup {
    id: root
    visible: S.LocalSend.connected
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.LocalSend.hasIncomingFiles ? T.Config.accent : T.Config.surfaceText
    iconText: S.LocalSend.sendingFile ? "󰔟" : S.LocalSend.icon
}
