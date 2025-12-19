import Quickshell
import Quickshell.Io
import qs.commonwidgets
import qs.services as S

BarIcon {
    id: root
    mouseEnabled: true
    iconText: "󰨸"

    Process {
        id: clipboard
    }

    function performLeftClickAction(){
        S.PopupManager.closeAll()
        clipboard.command = ["uwsm", "app", "--", "walker", "--provider", "clipboard"]
        clipboard.running = true
    }

    function performRightClickAction(){
        clipboard.command = ["cliphist", "wipe"]
        clipboard.running = true
    }
}
