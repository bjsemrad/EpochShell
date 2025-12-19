import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        width: parent.width
        spacing: 10
        Text {
            text: "Microphone" + (Pipewire.defaultAudioSource ? " - " + Pipewire.defaultAudioSource?.description : "")
            color: T.Config.surfaceText
            font.bold: true
            font.pointSize: 11
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true
            elide: Text.ElideRight
            clip: true
        }

        MicVolumeSlider {}
    }
}
