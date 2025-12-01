import "../commonwidgets"
import Quickshell
import Quickshell.Io
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
