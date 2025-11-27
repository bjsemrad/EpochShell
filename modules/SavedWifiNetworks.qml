import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../services" as S
import "../theme" as T
import "../commonwidgets"

Rectangle {
    id: root
    width: parent.width
    radius: 8
    color: "transparent"
    implicitHeight: column.implicitHeight + 8

    property string pendingSsid: ""
    property int pendingIndex: -1

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: 4
        spacing: 10

        Text {
            text: "Saved Networks"
            color: T.Config.fg
            font.pixelSize: 13
            Layout.leftMargin: 4
        }

        Repeater {
            model: S.NetworkMonitor.savedAccessPoints

            delegate: SavedNetworkRow {
                width: root.width
                ssid: model.ssid
            }
        }

     }
}
