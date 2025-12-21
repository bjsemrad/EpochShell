import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.commonwidgets
import qs.services as S

BarGroupIconPopup {
    id: root

    mouseEnabled: true
    hoverEnabled: false
    visible: S.NixService.updatesAvailable
    iconSet: ["󱄅"]
}
