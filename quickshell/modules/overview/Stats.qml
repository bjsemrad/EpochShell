import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.commonwidgets
import qs.theme as T

Rectangle {
    id: root
    Layout.fillWidth: true
    height: 120
    radius: T.Config.cornerRadius
    color: T.Config.surfaceContainer

    property real cpu
    property real mem
    property real disk
    property real net_mbps
    property var container

    GridLayout {
        id: grid
        anchors.centerIn: parent
        anchors.left: parent.left
        anchors.right: parent.right
        columns: 4
        rows: 1
        columnSpacing: 12

        RoundStat {
            label: "CPU"
            value: cpu
            displayText: Math.round(value * 100) + "%"
            displayIcon: ""
        }

        RoundStat {
            label: "Memory"
            value: mem
            displayText: Math.round(value * 100) + "%"
            displayIcon: ""
        }

        RoundStat {
            label: "Disk"
            value: disk
            displayText: Math.round(value * 100) + "%"
            displayIcon: "󰋊"
        }

        RoundStat {
            label: "Network"
            value: net_mbps / 1000
            displayText: net_mbps + "mb/s"
            displayIcon: "󰓅"
        }
    }

    Timer {
        id: pollTimer
        interval: 1000
        running: container.open
        repeat: true
        onTriggered: statsProc.running = true
    }

    readonly property string configDir: Quickshell.shellDir

    Process {
        id: statsProc
        command: [configDir + "/stats.py"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var obj = JSON.parse(text);
                    cpu = obj.cpu;
                    mem = obj.mem;
                    disk = obj.disk;

                    var norm = Math.round(Math.max(1.0, obj.net_mbps));
                    net_mbps = norm;
                } catch (e) {
                    console.log("stats parse error:", e, text);
                }
            }
        }
    }

    Component.onCompleted: statsProc.running = true
}
