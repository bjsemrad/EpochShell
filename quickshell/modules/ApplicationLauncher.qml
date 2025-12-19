import Quickshell
import Quickshell.Io
import qs.commonwidgets

BarIcon {
    id: root
    mouseEnabled: true
    iconText: "󰀻"

    Process {
        id: walker
        command: ["uwsm", "app", "--", "walker"]
    }

    function performLeftClickAction(){
        walker.running = true
    }
}
