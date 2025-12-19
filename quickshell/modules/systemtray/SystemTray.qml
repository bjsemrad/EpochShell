import qs.commonwidgets
import qs.services as S
import Quickshell
import Quickshell.Services.SystemTray

BarIconPopup {
    id: root
    visible: S.SystemTray.hasTrayItems()
    mouseEnabled: true
    hoverEnabled: true
    iconText:  "󱊖"
}
