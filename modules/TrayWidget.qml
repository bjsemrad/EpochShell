import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray


Item {
    id: tray
    property bool expanded: false
    property int collapsedWidth: 28
    property int expandedWidth: 180

    anchors.right: parent.right
    width: expanded ? expandedWidth : collapsedWidth
    height: 32

    Behavior on width {
        NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: expanded ? "#33373c" : "transparent"

        Row {
            id: iconRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            // ▶ main "tray" indicator (always visible)
            IconImage {
                source:  Quickshell.iconPath("view-grid-symbolic")
                width: 18; height: 18
            }

             // actual system tray icons
            Repeater {
                id: trayRepeater
                model: expanded ? SystemTray.items : []
                delegate: Item {

                            // Forces a real area
                        implicitWidth: 28
                    implicitHeight: 28
                    width: 28
                    height: 28



                IconImage {
                    width: 24
                    height: 24
                    source: modelData.icon

                    // 🧩 wait until we actually have a valid object
                    Component.onCompleted: {
                        const it = modelData?.item
                        if (it) {
                            it.parent = this
                            // it.anchors.fill = this
                        }
                    }
                     MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                    // if (mouse.button === Qt.LeftButton) {
                        // normal tray "activate" click
                        modelData.activate(mouse.screenX, mouse.screenY)
                    // }

                    // if (mouse.button === Qt.RightButton) {
                        // open the tray icon's real context menu
                        // modelData.activate(mouse.screenX, mouse.screenY)
                    // }
                        }
                    }
                }
            }
        }

            // // ▶ actual live tray icons
            // Repeater {
            //     model: expanded ? SystemTray.items : null
            //
            //     delegate: Item {
            //         width: 20
            //         height: 20
            //         // iconSize: 18
            //         anchors.verticalCenter: parent.verticalCenter
            //          // reparent the real tray item
            //         Component.onCompleted: modelData.item.parent = this
            //         // optional styling
            //         // color: "#f4f4f4"
            //         // hoverColor: "#ffffff"
            //
            //         // optional: tooltip from the service
            //         // ToolTip.visible: hovered
            //         // ToolTip.text: tooltip
            //     }
            // }
        }

        // ▶ hover behaviour
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: tray.expanded = true
            onExited: tray.expanded = false
        }
    }
}

// Item {
//     id: tray
//     property bool expanded: false
//     property int collapsedWidth: 28
//     property int expandedWidth: 180
//
//      anchors.right: parent.right
//     width: expanded ? expandedWidth : collapsedWidth
//     height: 32
//
//     Rectangle {
//         anchors.fill: parent
//         radius: 8
//         color: expanded ? "#33373c" : "transparent"
//
//         Row {
//             id: iconRow
//             anchors.centerIn: parent
//             spacing: 8
//
//             // "Main tray" icon that is always visible
//             IconImage {
//                 source:  Quickshell.iconPath("view-grid-symbolic")
//                 width: 18
//                 height: 18
//             }
//
//             // Actual tray icons – shown only when expanded
//             Repeater {
//                 model: expanded ? SNIModel.instances : 0
//                 delegate: IconImage {
//                     source: modelData.icon
//                     width: 18; height: 18
//                 }
//             }
//         }
//
//         // Hover detection
//         MouseArea {
//             anchors.fill: parent
//             hoverEnabled: true
//             onEntered: tray.expanded = true
//             onExited: tray.expanded = false
//         }
//     }
//
//     // Smooth width animation
//     Behavior on width {
//         NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
//     }
// }
