import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Night mode, in the drawer's alert row.
//
// Shown only while the screen is actually being warmed: a screen that has gone orange is worth
// explaining, and the rest of the time the toggle lives in the system menu. Clicking hands the
// screen back.
BarIcon {
    id: root
    visible: S.NightLight.connected && S.NightLight.enabled
    mouseEnabled: true
    iconText: S.NightLight.icon
    iconColor: T.Config.orange

    function performLeftClickAction() {
        S.NightLight.toggle();
    }
}
