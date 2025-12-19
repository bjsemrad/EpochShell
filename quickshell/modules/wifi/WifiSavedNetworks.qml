import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: column.implicitHeight

    property string pendingSsid: ""
    property int pendingIndex: -1

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Saved Networks"
            color: T.Config.surfaceText
            font.pixelSize: 13
        }

        Repeater {
            model: S.Network.savedAccessPoints

            delegate: WifiSavedNetworkRow {
                width: root.width
                ssid: model.ssid
            }
        }
    }
}
