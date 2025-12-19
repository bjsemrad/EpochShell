import qs.theme as T
import qs.services as S
import qs.commonwidgets

BarIconPopup {
    id: root
    visible: S.Network.wifiDevice && !S.Network.ethernetConnected
    mouseEnabled: true
    hoverEnabled: false
    iconText:  {
        const s = S.Network.strength
        if (!S.Network.wifiConnected) return "󰤭"
        if (s >= 75) return "󰤨"
        if (s >= 50) return "󰤢"
        if (s >= 25) return "󰤟"
        return "󰤟"
    }
}
