import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry shown only while the machine is being held awake.
//
// It sits with the alerts rather than the drawer tools for the same reason the recording indicator
// does: a machine that will not sleep is a state worth seeing with the drawer shut, and one nobody
// can see is one that stays awake all night. Clicking it lets the machine idle again.
BarIcon {
    id: root
    visible: S.StayAwake.connected && S.StayAwake.enabled
    mouseEnabled: true
    iconText: S.StayAwake.icon

    function performLeftClickAction() {
        S.StayAwake.toggle();
    }
}
