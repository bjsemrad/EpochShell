import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.theme as T

// Keyboard backlight OSD.
//
// Shaped like BrightnessOSD -- watch a value, show a bar for a second when it moves -- but read
// from sysfs rather than through brightnessctl. The screen backlight polls two processes four
// times a second between them; a keyboard backlight is worth less than that, and the same numbers
// are one file read away.
//
// The device is found rather than named: it is `chromeos::kbd_backlight` on a Framework,
// `tpacpi::kbd_backlight` on a ThinkPad, `smc::kbd_backlight` on a Mac. A machine with none simply
// never shows this.
Scope {
    id: root

    property string device: ""
    property int maxBrightness: 0
    property real level: 0.0
    property bool initialized: false
    property bool shouldShowOsd: false

    readonly property bool available: device.length > 0 && maxBrightness > 0

    Process {
        id: findDevice
        running: true
        command: ["sh", "-c", "for d in /sys/class/leds/*kbd_backlight*; do [ -r \"$d/brightness\" ] && printf %s \"$d\" && break; done"]
        stdout: StdioCollector {
            id: deviceOut
            waitForEnd: true
        }
        onExited: root.device = String(deviceOut.text || "").trim()
    }

    FileView {
        id: maxFile
        path: root.device.length > 0 ? root.device + "/max_brightness" : ""
        printErrors: false
        onLoaded: root.maxBrightness = parseInt(text()) || 0
    }

    FileView {
        id: brightnessFile
        path: root.device.length > 0 ? root.device + "/brightness" : ""
        printErrors: false
        onLoaded: root.apply(parseInt(text()))
    }

    // sysfs does not reliably tell anyone when an LED attribute changes, so this is a poll -- but
    // a poll that reads a file rather than starting a process.
    Timer {
        interval: 250
        running: root.available
        repeat: true
        onTriggered: brightnessFile.reload()
    }

    function apply(value) {
        if (!root.available || isNaN(value)) return;
        const next = Math.max(0, Math.min(1, value / root.maxBrightness));
        // The first reading is the state at login, which nobody asked to see.
        if (!root.initialized) {
            root.initialized = true;
            root.level = next;
            return;
        }
        if (Math.abs(next - root.level) < 0.001) return;
        root.level = next;
        root.triggerOSD();
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
                        text: "󰌌"
                        font.pixelSize: 30
                        font.family: T.Config.fontFamily
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

                            implicitWidth: parent.width * root.level
                            radius: parent.radius
                            color: T.Config.surfaceText
                        }
                    }
                }
            }
        }
    }
}
