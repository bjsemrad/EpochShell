import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry for flake updates.
//
// It lives with the alerts rather than the drawer tools because that is what it is: something to
// notice when there is something to notice. With updates waiting it shows whether the drawer is
// open or shut, and otherwise only while the drawer is open, so a system that is up to date takes
// no room on the bar.
BarIconPopup {
    id: root
    visible: S.NixUpdates.connected && S.NixUpdates.available
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.NixUpdates.hasUpdates ? T.Config.accent : T.Config.surfaceText
    iconText: S.NixUpdates.icon
}
