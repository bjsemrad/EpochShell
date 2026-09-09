import qs.commonwidgets
import qs.services as S

BarIconPopup {
    id: root
    visible: S.Tailscale.connected || S.Tailscale.hasIncomingFiles
    mouseEnabled: true
    hoverEnabled: false
    iconText: {
        if (S.Tailscale.hasIncomingFiles) return "󰈔";
        return S.Tailscale.connected ? "󰒄" : "󰅛";
    }
}
