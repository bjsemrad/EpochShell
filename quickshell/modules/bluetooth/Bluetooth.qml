import qs.commonwidgets
import qs.services as S
BarIconPopup {
    id: root
    mouseEnabled: true
    hoverEnabled: false
    iconText: {
        return S.Bluetooth.enabled ? S.Bluetooth.connected ? "󰂱" : "󰂯" : "󰂲"
    }
}
