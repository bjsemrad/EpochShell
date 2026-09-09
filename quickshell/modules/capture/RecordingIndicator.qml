import QtQuick
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

// Bar entry shown only while something is recording.
//
// It sits with the alert items rather than the drawer tools, so it stays visible when the drawer
// is collapsed: a recording nobody can see is a recording that runs until the disk fills. The dot
// pulses, the elapsed time counts up, and clicking it stops the recording -- the one thing anyone
// wants from this widget.
Rectangle {
    id: root
    visible: S.Capture.recording
    color: mouseArea.containsMouse ? T.Config.surfaceContainer : "transparent"
    radius: T.Config.popupRadius
    border.width: 1
    border.color: "transparent"
    implicitWidth: contents.implicitWidth + T.Config.barModuleHorizontalPadding
    implicitHeight: contents.implicitHeight + T.Config.barModuleVerticalPadding

    RowLayout {
        id: contents
        anchors.centerIn: parent
        spacing: T.Config.barIconTextSpacing

        Text {
            id: dot
            text: "󰑊"
            font.pixelSize: T.Config.barIconSize
            font.family: T.Config.fontFamily
            color: T.Config.red
            Layout.alignment: Qt.AlignVCenter

            SequentialAnimation on opacity {
                running: S.Capture.recording
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.35; duration: 700; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.35; to: 1.0; duration: 700; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            text: S.Capture.recordingElapsed
            font.pixelSize: T.Config.fontSizeNormal
            font.family: T.Config.fontFamily
            color: T.Config.surfaceText
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: S.Capture.stopRecording()
    }
}
