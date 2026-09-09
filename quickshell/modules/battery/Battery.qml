import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.commonwidgets
import qs.services as S

BarIconPopup {
    id: root

    mouseEnabled: true
    // Click, not hover. The panel carries a stay-awake switch and a live power readout, which are
    // things to reach for rather than glance at -- and a panel that opens on hover closes itself
    // the moment the pointer leaves on its way to that switch.
    hoverEnabled: false
    visible: S.BatteryService.hasBattery
    iconText: S.BatteryService.batteryIcon()
}
