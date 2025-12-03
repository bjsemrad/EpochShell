import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services" as S
import "../theme" as T
import "../commonwidgets"

Rectangle {
    id: systemOptionsSection
    width: parent.width
    implicitHeight: contents.implicitHeight
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"

    property bool expanded: false


    Column {
        id:contents
        anchors.margins: 4
        anchors.fill: parent
        spacing: 6
            Rectangle {
                id: power
                implicitHeight: 30
                width: parent.width
                radius: 10
                color: T.Config.bg0
                Row {
                    width: parent.width
                    spacing: 10

                    PanelHeaderIcon {
                        id: systemMonitorSettings
                        iconText: "⏻"
                        anchors.centerIn: parent
                        function onClick(){
                        }
                    }


                    // Text {
                    //     id: avText
                    //     text: "⏻"
                    //     color: T.Config.fg
                    //     font.pixelSize: 24
                    //     anchors.centerIn: parent
                    //     Layout.leftMargin: 20
                    //
                    //     MouseArea {
                    //         anchors.fill: parent
                    //         hoverEnabled: true
                    //         cursorShape: Qt.PointingHandCursor
                    //
                    //         onClicked: function() {
                    //         }
                    //     }
                    // }
                }
        }
    }
}
