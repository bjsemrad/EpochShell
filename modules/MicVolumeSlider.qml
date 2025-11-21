import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme" as T
// ----- ROUNDED SLIDER -----
Rectangle {
    property var audioInterface: Pipewire.defaultAudioSource
    // width: parent.width
     // color: T.Config.black
     // radius: 10
     // height: 24

       width: parent ? parent.width : 220
      height: 60
      radius: 40

         readonly property color _containerBg: T.Config.bg0

    color: _containerBg
    border.color: T.Config.grey
    border.width: 1
    antialiasing: true

        IconImage {
            anchors.left: parent.left
            anchors.leftMargin: 10
             anchors.verticalCenter: parent.verticalCenter
            implicitSize: 24
            source: Quickshell.iconPath(audioIcon(volume.value, audioInterface.audio.muted))
        }

        function audioIcon(vol, muted) {
            if (muted) return "microphone-sensitivity-muted-symbolic" 
            if (vol >= 0) return "microphone-sensitivity-high-symbolic"
            return "microphone-sensitivity-muted-symbolic"
        }

        	
// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSource ]
	}

        
    	Connections {
		target: audioInterface?.audio

                function updateSlider() {
                    volume.value = (audioInterface?.audio.volume ?? 0) * 100
                }
                
                function onVolumeChanged() {
                    updateSlider()
		}


                function onMutedChanged() {
                    updateSlider()
                }

                Component.onCompleted: updateSlider()

        }

        Slider {
            anchors.centerIn: parent
        id: volume
        width: 200
        height: 20
        from: 0; to: 100
        value: 25

        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: T.Config.grey
        }

        handle: Rectangle {
            width: 10
            height: 10
            radius: 6
            color: T.Config.fg
            anchors.verticalCenter: parent.verticalCenter
        }

        // fill bar
        contentItem: Rectangle {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: volume.position * volume.width
            height: 10
            radius: height / 2
            color: T.Config.fg
        }
    }
    // }
}

