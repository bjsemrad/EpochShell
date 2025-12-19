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

    topLeftRadius: 10
    topRightRadius: 10
    color: connectedOverview.expanded ? T.Config.accentLightShade : mouseAreaMain.containsMouse ? T.Config.surfaceContainerHigh : T.Config.surfaceContainer

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1
        color: overviewSelectedColor()
    }

    implicitHeight: 50

    Layout.fillWidth: true
    signal clicked

    MouseArea {
        id: mouseAreaMain
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }

    function overviewSelectedColor() {
        return connectedOverview.expanded ? T.Config.accent : T.Config.surfaceText;
    }

    RowLayout {
        anchors.fill: parent
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
            id: icon
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 24
            color: overviewSelectedColor()
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: connectedOverview.expanded ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.subtitle
                color: connectedOverview.expanded ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: 11
                elide: Text.ElideRight
                clip: true
                Layout.fillWidth: true
            }
        }
    }
}
