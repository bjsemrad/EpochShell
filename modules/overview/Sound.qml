import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.audio
import qs.commonwidgets

ColumnLayout {
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
}
