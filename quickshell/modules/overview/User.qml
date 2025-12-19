import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme as T

Rectangle {
    id: header
    Layout.fillWidth: true
    height: 80
    radius: T.Config.cornerRadius
    color: T.Config.surfaceContainer

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 40
            height: 40
            radius: 999
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: ""
                color: T.Config.accent
                font.pixelSize: 32
                font.bold: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: username
                color: T.Config.surfaceText
                font.pixelSize: 16
                font.bold: true
                elide: Text.ElideRight
            }
            Text {
                text: Qt.formatDateTime(sysclk.date, "dddd, MMM d, yyyy")
                color: T.Config.surfaceText
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        SystemOptions {}
    }
}
