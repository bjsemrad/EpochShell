import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import Quickshell.Io
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    radius: 6
    color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

    property string ssid: ""

    Rectangle {
        width: row.implicitWidth
        height: parent.height
        color: "transparent"
        RowLayout {
            id: row
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            width: parent.width

            Text {
                text: "󰤨"
                font.pixelSize: 18
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 10
                color: T.Config.surfaceText
            }

            Text {
                text: root.ssid
                Layout.alignment: Qt.AlignVCenter
                color: T.Config.surfaceText
                font.pixelSize: 13
            }

            Spinner {
                id: wifiSpinner
                running: S.Network.wifiConnecting && S.Network.wifiConnectingTo === root.ssid
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                S.Network.connectTo(root.ssid);
            }
        }
    }
}
