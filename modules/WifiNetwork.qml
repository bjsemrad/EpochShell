import '../commonwidgets'
import '../services' as S

BarIconPopup {
    id: root
    mouseEnabled: true
    iconText:  {
        const s = S.NetworkMonitor.strength
        if (!S.NetworkMonitor.wifiConnected) return "󰤭"
        if (s >= 75) return "󰤨"
        if (s >= 50) return "󰤢"
        if (s >= 25) return "󰤟"
        return "󰤟"
    }
}
