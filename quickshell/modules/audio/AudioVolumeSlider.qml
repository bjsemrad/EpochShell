import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T
import qs.commonwidgets

VolumeSlider {
    audioInterface: Pipewire.defaultAudioSink
    iconText: {
        const vol = audioInterface?.audio.volume * 100
        if (audioInterface?.audio.muted) return "󰝟"
        if (vol >= 65) return "󰕾"
        if (vol >= 25) return "󰖀"
        return "󰕿"
    }
}
