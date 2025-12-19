import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.theme as T

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink?.audio : null

        function onVolumeChanged() {
            if (!root.initialized) {
                root.initialized = true;
                return;
            }
            root.shouldShowOsd = true;
            hideTimer.restart();
        }

        function onMutedChanged() {
            let audio = Pipewire.defaultAudioSink.audio;
            let muted = audio.muted ?? false;

            if (!root.initialized) {
                root.initialized = true;
                root.lastMuted = muted;
                return;
            }

            if (muted !== lastMuted) {
                root.lastMuted = muted;
                root.shouldShowOsd = true;
                hideTimer.restart();
            }
        }
    }

    property bool shouldShowOsd: false
    property bool initialized: false
    property bool lastMuted: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {

            anchors {
                top: true
            }
            margins {
                top: 50
            }
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: T.Config.background
                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    Text {
                        text: {
                            Pipewire.defaultAudioSink.audio.muted ? "" : "";
                        }
                        font.pixelSize: 30
                        color: T.Config.surfaceText
                    }

                    Rectangle {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true

                        implicitHeight: 10
                        radius: 20
                        color: T.Config.surfaceVariant

                        Rectangle {
                            color: T.Config.surfaceText
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                            radius: parent.radius
                        }
                    }
                }
            }
        }
    }
}
