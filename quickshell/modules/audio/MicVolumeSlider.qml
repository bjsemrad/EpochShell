import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T
import qs.commonwidgets
VolumeSlider {
    audioInterface: Pipewire.defaultAudioSource
    iconText: {
        if (audioInterface?.audio.muted) return ""
        return ""
    }
}
