import qs.commonwidgets
import qs.services as S
import qs.theme as T

// Bar entry for recording, sitting with the drawer tools next to the capture camera.
//
// It stands down while a recording is running: RecordingIndicator takes its place with the dot and
// the elapsed clock, so exactly one thing on the bar is about recording at any moment rather than
// an icon and an indicator saying it twice.
//
// Present whenever the backend is reachable, exactly like the capture trigger, rather than only
// when wf-recorder is installed. Hiding it there would be indistinguishable from the feature not
// existing, which leaves nowhere to say why; the panel has room to name the missing tool, and the
// dimmed icon says something is wrong before it is even opened.
BarIconPopup {
    id: root
    visible: S.Capture.connected && !S.Capture.recording
    mouseEnabled: true
    hoverEnabled: false
    iconColor: S.Capture.recordAvailable ? T.Config.surfaceText : T.Config.outline
    iconText: "󰕧"
}
