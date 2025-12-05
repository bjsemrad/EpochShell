import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme" as T
Rectangle {
    width: parent.width
    implicitHeight: column.implicitHeight + 8
    color: "transparent"


    Column {
        id: column
        anchors.fill: parent
        width: parent.width
        spacing: 10
        Text {
            text: "Microphone" + (Pipewire.defaultAudioSource ? " - " + Pipewire.defaultAudioSource?.description : "")
            color: T.Config.fg
            font.bold: true
            font.pointSize: 11
            anchors.left: parent.left
            anchors.leftMargin: 5
        }

        MicVolumeSlider{}
    }
}

