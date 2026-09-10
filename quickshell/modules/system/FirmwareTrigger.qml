import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Firmware updates, in the drawer's alert row.
//
// Unlike the other alerts, this one is hidden even with the drawer open when there is nothing
// waiting: firmware is not something to check on, and an icon that only ever says "up to date"
// teaches people to stop looking at that corner of the bar. When something is waiting it shows in
// the accent colour whether the drawer is open or shut, the way flake updates do.
BarIconPopup {
    id: root
    visible: S.SystemInfo.connected && S.SystemInfo.hasFirmwareUpdates
    mouseEnabled: true
    hoverEnabled: false
    iconColor: T.Config.accent
    iconText: S.SystemInfo.firmwareIcon
}
