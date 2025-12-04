import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../theme" as T
Rectangle {
    id: contents
    implicitHeight: 40
    width: parent.width
    radius: 10
    color: "transparent"
    required property string icon
    required property string description
    function onClick() {
        console.log("Implementation Missing")
    }

    Rectangle {
        id: actionArea
        implicitHeight: 40
        width: parent.width 
        radius: 10
        color: actionMouseArea.containsMouse ? T.Config.activeSelection : "transparent"


        Row {
            anchors.leftMargin: 30
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                id: actionIcon
                text: icon
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                color: T.Config.fg
            }

            Text {
                id: actionText
                text: description
                font.pixelSize: 18
                anchors.verticalCenter: parent.verticalCenter
                color: T.Config.fg
            }
        }

         MouseArea {
            id: actionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                onClick()
            }

        }
    }
}


