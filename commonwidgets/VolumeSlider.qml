import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../theme" as T
Rectangle {
    required property var audioInterface
    required property var iconText
    width: parent.width
    height: 30
    radius: 40

    color: "transparent"
    antialiasing: true
    Rectangle {
        id: audioMuteUnmute
        implicitWidth: 40
        implicitHeight: 40
        radius: 20
        border.width: 2
        border.color: audioMouseArea.containsMouse ? T.Config.fg : "transparent"
        color: audioMouseArea.containsMouse ? T.Config.activeSelection : "transparent"
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
            text: iconText
            color: "white"
            font.bold: true
            font.pointSize: 18
        }

        MouseArea {
            id: audioMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                audioInterface.audio.muted = !audioInterface?.audio.muted
            }

        }
    }
 

	PwObjectTracker {
		objects: [ audioInterface ]
	}

    	Connections {
            target: audioInterface ? audioInterface.audio : null
            function updateSlider() {
                volume.value = audioInterface.audio.volume * 100
            }

            function onVolumeChanged() {
                updateSlider()
            }


            function onMutedChanged() {
                updateSlider()
            }
        }

        function updateSlider() {
            volume.value = audioInterface.audio.volume * 100
        }

        Component.onCompleted: updateSlider()

        Slider {
            anchors.centerIn: parent
            id: volume
            width: 200
            height: 20
            from: 0; to: 100
            value: 25

             MouseArea {
                anchors.fill: parent
                onPressed: (mouse) => mouse.accepted = false
                cursorShape: volume.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
            }

            function onValueChanged(){
                if (audioInterface) {
                    audioInterface.audio.volume = value / 100      // audio follows UI
                }
            }

            background: Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: T.Config.bg0
            }

            handle: Rectangle {
                width: 30
                height: 30
                radius: 15
                color: T.Config.bg2
                anchors.verticalCenter: parent.verticalCenter
                x: volume.visualPosition * (volume.width - width)
                Text {
                    text: Math.round(audioInterface.audio.volume * 100)
                    color: T.Config.fg
                    anchors.centerIn: parent
                }
            }

            contentItem: Rectangle {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                width: volume.visualPosition * volume.width
                height: 10
                radius: height / 2
                color: T.Config.blue
            }
        }
}

