import qs.commonwidgets
import qs.services as S

BarIconPopup {
    id: root
    visible: S.Network.tailscaleConnected
    mouseEnabled: true
    hoverEnabled: false
    iconText:  {
         return S.Tailscale.connected ? "󰒄" : "󰅛"
    }
}
