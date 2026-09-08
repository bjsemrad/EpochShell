import QtQuick
import Quickshell
import qs.commonwidgets
import qs.services as S

BarIconPopup {
    id: root
    visible: S.Notifications.doNotDisturb || S.Notifications.historyModel.count > 0
    mouseEnabled: true
    hoverEnabled: false
    iconText: S.Notifications.doNotDisturb ? "󰂛" : S.Notifications.unreadCount > 0 ? "󰂚" : "󰂜"

    onVisibleChanged: if (!root.visible && root.popup && root.popup.open) root.popup.hidePanel()
    onRightClicked: S.Notifications.toggleDoNotDisturb()
}
