import qs.commonwidgets
import qs.services as S
import qs.theme as T

BarIconPopup {
    id: root
    visible: S.Tailscale.connected || S.Tailscale.hasIncomingFiles
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.Tailscale.hasIncomingFiles ? T.Config.accent : T.Config.surfaceText
    iconText: {
        return S.Tailscale.connected ? "󰒄" : "󰅛";
    }
}
