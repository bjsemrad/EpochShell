// Spinner.qml
import QtQuick

Item {
    id: spinner
    width: 22
    height: 22
    visible: running
    property bool running: false
    property color color: "white"
    property real angle: 0

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            ctx.strokeStyle = spinner.color
            ctx.lineWidth = 3
            ctx.lineCap = "round"

            ctx.beginPath()
            ctx.arc(width/2, height/2, width/2 - 3,
                    spinner.angle,
                    spinner.angle + Math.PI * 1.3 ) // 75% arc
            ctx.stroke()
        }
    }

    // REAL animation source — rotates continuously
    NumberAnimation on angle {
        running: spinner.running
        loops: Animation.Infinite
        duration: 800
        from: 0
        to: Math.PI * 2
    }

    // Repaint canvas when angle changes
    onAngleChanged: canvas.requestPaint()
}

// import QtQuick
//
// Item {
//     id: spinner
//     width: 22
//     height: 22
//     visible: running
//
//     property bool running: false
//     property color color: "white"
//     property int arcWidth: 3
//
//     Canvas {
//         anchors.fill: parent
//         renderStrategy: Canvas.Cooperative
//         onPaint: {
//             var ctx = getContext("2d")
//             ctx.reset()
//             ctx.strokeStyle = spinner.color
//             ctx.lineWidth = spinner.arcWidth
//             ctx.beginPath()
//             ctx.arc(width/2, height/2, width/2 - spinner.arcWidth, startAngle, startAngle + Math.PI * 1.5)
//             ctx.stroke()
//         }
//     }
//
//     NumberAnimation on startAngle {
//         running: true
//         loops: Animation.Infinite
//         duration: 800
//         from: 0
//         to: Math.PI * 2
//     }
//
//     property real startAngle: 0
// }
