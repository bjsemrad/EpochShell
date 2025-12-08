import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.theme as T

Rectangle {
    id: root
    required property var connectedOverview
    property alias iconSource: icon.text
    property string title: ""
    property string subtitle: ""
    property bool accent: false

    radius: 10
    color: connectedOverview.visible ? T.Config.accentLightShade : mouseAreaMain.containsMouse ? T.Config.activeSelection : T.Config.bgDark
    border.width: connectedOverview.visible ? 1 : 0
    border.color: overviewSelectedColor()

    implicitWidth: 150
    implicitHeight: 50

    // Simple click handler you can hook into
    signal clicked()

    MouseArea {
        id: mouseAreaMain
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
    
    function overviewSelectedColor(){
        return connectedOverview.visible ? T.Config.accent : T.Config.fg
    }

    RowLayout {
        // anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 14
        spacing: 12

            Text {
                id: icon
                // Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 24
                color: overviewSelectedColor()
            }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: connectedOverview.visible ? T.Config.accent : T.Config.fg
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                text: root.subtitle
                color: T.Config.fg
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
