import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../commonwidgets"
import "../services" as S

BarIconPopup {
    id: root

    mouseEnabled: true
    hoverEnabled: true
    visible: S.BatteryService.hasBattery()
    iconText: S.BatteryService.batteryIcon()
}
