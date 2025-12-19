import QtQuick
import qs.theme as T

Item {
    id: spinner
    width: 22
    height: 22
    visible: running
    property bool running: false
    property color color: T.Config.surfaceText
    property real angle: 0

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            ctx.strokeStyle = spinner.color;
            ctx.lineWidth = 3;
            ctx.lineCap = "round";

            ctx.beginPath();
            ctx.arc(width / 2, height / 2, width / 2 - 3, spinner.angle, spinner.angle + Math.PI * 1.3); // 75% arc
            ctx.stroke();
        }
    }

    NumberAnimation on angle {
        running: spinner.running
        loops: Animation.Infinite
        duration: 800
        from: 0
        to: Math.PI * 2
    }

    onAngleChanged: {
        canvas.requestPaint();
    }
}
