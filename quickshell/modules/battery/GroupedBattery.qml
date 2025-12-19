import qs.commonwidgets
import qs.services as S

BarGroupIconPopup {
    id: root
    mouseEnabled: true
    hoverEnabled: true
    visible: S.BatteryService.hasBattery
    iconSet: [S.BatteryService.batteryIcon()]
}
