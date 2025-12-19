import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme as T

Item {
    id: root
    width: 120
    height: 120

    property real value: 0.37
    property string label: "CPU"
    property string displayText: "37%"
    property string displayIcon: ""
    property color accentColor: T.Config.accent
    property color bgColor: T.Config.surfaceContainer

    onValueChanged: gauge.requestPaint()

    // pill background
    Rectangle {
        id: pill
        anchors.fill: parent
        radius: 20
        color: bgColor
    }

    // circular arc gauge
    Canvas {
        id: gauge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12
        width: parent.width - 24
        height: width

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2;
            var cy = height / 2;
            var r = width / 2 - 4;

            var start = -Math.PI * 0.75;   // -135°
            var end = Math.PI * 0.75;   //  135°

            // background arc
            ctx.strokeStyle = "#3a3d44";
            ctx.lineWidth = 5;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, end, false);
            ctx.stroke();

            // foreground arc
            var vEnd = start + (end - start) * Math.max(0, Math.min(1, root.value));
            ctx.strokeStyle = accentColor;
            ctx.lineWidth = 5.5;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, vEnd, false);
            ctx.stroke();
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 5
            Text {
                text: root.displayIcon
                color: T.Config.surfaceText
                font.pixelSize: 14
            }

            // center text
            Text {
                text: root.displayText
                color: T.Config.surfaceText
                font.pixelSize: 14
            }
        }
    }

    // Column {
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: 12
    //     spacing: 4
    //
    //     Text {
    //         text: root.label
    //         color: T.Config.surfaceText
    //         font.pixelSize: 12
    //         horizontalAlignment: Text.AlignHCenter
    //         width: parent.width
    //     }
    //
    //     Rectangle {
    //         width: 20
    //         height: 4
    //         radius: 2
    //         color: accentColor
    //         anchors.horizontalCenter: parent.horizontalCenter
    //     }
    // }
}
