import QtQuick
import qs.commonwidgets
import qs.services as S

BarIcon {
    id: root
    mouseEnabled: true
    iconText: "󰀻"

    // The overlay itself is owned by the shell root: this icon exists once per screen, and every
    // copy toggles the one shared launcher window.
    function performLeftClickAction() {
        if (S.PopupManager.launcher) S.PopupManager.launcher.toggle();
    }
}
