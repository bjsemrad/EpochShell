import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry for capture. Present whenever the backend is reachable: taking a screenshot is
// something the user initiates, not a state to indicate, so it does not hide itself when there is
// nothing to report. A missing grim is said inside the panel, where there is room to say which
// tool it is.
BarIconPopup {
    id: root
    visible: S.Capture.connected
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.Capture.busy ? T.Config.accent : T.Config.surfaceText
    iconText: S.Capture.busy ? "󰔟" : S.Capture.icon
}
