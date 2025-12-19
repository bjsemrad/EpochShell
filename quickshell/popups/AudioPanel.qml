import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules.audio
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: audioPopup
    trigger: trigger
    popupWidth: Math.max(T.Config.audioPopupWidth, header.implicitWidth, vol.implicitWidth, output.implicitWidth, mic.implicitWidth, input.implicitWidth)

    AudioHeader{
        id: header
    }
    ComponentSplitter{}
    AudioVolumeRow {
        id: vol
    }
    ComponentSplitter{}
    AvailableAudioOutputs{
        id: output
    }
    ComponentSplitter{}
    MicVolumeRow{
        id: mic
    }
    ComponentSplitter{}
    AvailableAudioInputs{
        id: input
    }
    ComponentSpacer{}

    onVisibleChanged: {
        if (visible){
            S.PopupManager.closeOthers(audioPopup)
        }
    }

    Component.onCompleted: {
        S.PopupManager.register(audioPopup)
    }
}

