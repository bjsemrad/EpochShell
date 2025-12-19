import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.theme as T

RowLayout {
    required property var audioInterface
    required property var iconText
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    spacing: 10
    antialiasing: true

    Rectangle {
        id: audioMuteUnmute
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        border.width: 2
        border.color: audioMouseArea.containsMouse ? T.Config.surfaceText : "transparent"
        color: audioMouseArea.containsMouse ? T.Config.activeSelection : "transparent"
        Layout.alignment: Qt.AlignVCenter
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.centerIn: parent
            text: iconText
            color: T.Config.surfaceText
            font.bold: true
            font.pointSize: 18
        }

        MouseArea {
            id: audioMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                audioInterface.audio.muted = !audioInterface?.audio.muted;
            }
        }
    }

    PwObjectTracker {
        objects: [audioInterface]
    }

    Connections {
        target: audioInterface ? audioInterface.audio : null
        function updateSlider() {
            volume.value = audioInterface.audio.volume * 100;
        }

        function onVolumeChanged() {
            updateSlider();
        }

        function onMutedChanged() {
            updateSlider();
        }
    }

    function updateSlider() {
        volume.value = audioInterface?.audio.volume * 100;
    }

    Component.onCompleted: updateSlider()

    Slider {
        id: volume
        Layout.alignment: Qt.AlignVCenter
        width: 200
        height: 20
        from: 0
        to: 100
        value: 25

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = false
            cursorShape: volume.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        }

        onValueChanged: {
            if (audioInterface) {
                audioInterface.audio.volume = value / 100;
            }
        }

        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: T.Config.surfaceVariant
        }

        handle: Rectangle {
            width: 30
            height: 30
            radius: 15
            color: T.Config.surfaceContainerHighest
            anchors.verticalCenter: parent.verticalCenter
            x: volume.visualPosition * (volume.width - width)
            Text {
                text: Math.round(audioInterface?.audio.volume * 100)
                color: T.Config.surfaceText
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
            color: T.Config.accent
        }
    }
}
