import qs.commonwidgets
import qs.services as S
import qs.theme as T

// The idle inhibitor, in the bar drawer.
//
// It follows the rule Tailscale and LocalSend use for their alerts: on show whenever it is
// actually holding the machine awake, and otherwise only while the drawer is open. A machine that
// will not sleep is worth seeing with the drawer shut, and the control is worth reaching for
// before a presentation starts -- but an icon that says "everything is normal" earns no room on a
// collapsed bar.
//
// It is also the only way to reach this on a desktop: the battery panel carries the same switch,
// and hides itself entirely on a machine with no battery, which still locks and sleeps.
//
// The glyph says what will happen rather than what is set: "zZ" when the machine will sleep
// normally, the same struck through when it is being held awake.
BarIcon {
    id: root
    // Overridden where it is placed, which decides when an alert shows.
    visible: S.StayAwake.connected && S.StayAwake.available
    mouseEnabled: true
    iconText: S.StayAwake.enabled ? "󰒳" : "󰒲"
    iconColor: S.StayAwake.enabled ? T.Config.accent : T.Config.outline

    function performLeftClickAction() {
        S.StayAwake.toggle();
    }
}
