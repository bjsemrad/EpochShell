import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.theme as T
import qs.services as S

Rectangle {
    id: workspaceFrame
    radius: 20
    color: "transparent"
    Layout.alignment: Qt.AlignVCenter

    property int padding: 10
    implicitHeight: inner.implicitHeight + padding
    implicitWidth: inner.implicitWidth + padding * 2

    RowLayout {
        id: inner
        spacing: padding * 2
        anchors.centerIn: parent

        Repeater {
            model: S.NiriService.workspaces

            delegate: WrapperMouseArea {
                required property var modelData
                readonly property int wsId: modelData.idx

                implicitWidth: ws.implicitWidth
                implicitHeight: ws.implicitHeight

                cursorShape: Qt.PointingHandCursor
                readonly property bool active: modelData.isFocused

                onPressed: S.NiriService.switchToWorkspace(modelData)

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    Text {
                        id: ws
                        anchors.centerIn: parent
                        text: wsId
                        font.pixelSize: 16
                        font.weight: active ? Font.Bold : Font.Normal
                        font.family: T.Config.fontFamily
                        color: active ? T.Config.active : T.Config.inactive
                    }
                }
            }
        }
    }
}
