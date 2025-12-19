import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.theme as T

Scope {
    id: root

    property real brightness: 0.0      // 0‒1 normalized
    property bool initialized: false
    property bool shouldShowOsd: false

    property bool hasBacklight: false

    Process {
        id: backlightListProc
        running: true
        command: ["brightnessctl", "--list"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                root.hasBacklight = data.indexOf("class 'backlight'") !== -1;
                if (root.hasBacklight)
                    backlightGetValueProc.running = true;
            }
        }
    }

    Process {
        id: backlightGetValueProc
        running: false
        command: ["sh", "-c", "echo \"$(brightnessctl g) $(brightnessctl m)\""]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const s = data.trim().split(" ");
                if (s.length >= 2) {
                    let pct = (parseInt(s[0]) / parseInt(s[1]));
                    if (!root.initialized) {
                        root.initialized = true;
                        root.brightness = pct;
                        return;
                    }

                    if (Math.abs(pct - root.brightness) > 0.001) {
                        root.brightness = pct;
                        root.triggerOSD();
                    }
                }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (root.hasBacklight)
                backlightGetValueProc.running = true;
        }
    }

    function triggerOSD() {
        root.shouldShowOsd = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.top: true
            margins.top: 50
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
                        text: ""
                        font.pixelSize: 30
                        Layout.alignment: Qt.AlignVCenter
                        color: T.Config.surfaceText
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: T.Config.surfaceVariant

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * root.brightness
                            radius: parent.radius
                            color: T.Config.surfaceText
                        }
                    }
                }
            }
        }
    }
}
