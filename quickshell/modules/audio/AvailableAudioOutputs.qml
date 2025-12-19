import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T

AvailableAudio {
    id: audioOutputSection

    type: "Outputs"
    defaultAudioNode: Pipewire.defaultAudioSink

    function isAudioType(node){
        return (node.isSink && node.audio)
    }
}
