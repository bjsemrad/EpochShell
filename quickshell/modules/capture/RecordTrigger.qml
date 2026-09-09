import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry for recording, sitting with the drawer tools next to the capture camera.
//
// It is a way in, not a status light: while something is recording the elapsed time belongs in
// RecordingIndicator, which stays visible with the drawer shut. This one only goes red so the
// tool and the alert agree about what is going on when both are on screen.
BarIconPopup {
    id: root
    visible: S.Capture.connected && S.Capture.recordAvailable
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.Capture.recording ? T.Config.red : T.Config.surfaceText
    iconText: "󰕧"
}
