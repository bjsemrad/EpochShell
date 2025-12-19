import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T
import qs.commonwidgets

AvailableAudio {
    id: audioInputSection

    type: "Inputs"
    defaultAudioNode: Pipewire.defaultAudioSource

    function isAudioType(node){
        return (!node.isSink && node.audio)
    }
}
