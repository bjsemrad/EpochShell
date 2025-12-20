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
            model: Hyprland.workspaces.values

            delegate: WrapperMouseArea {
                required property var modelData
                readonly property int wsId: modelData.id

                implicitWidth: ws.implicitWidth
                implicitHeight: ws.implicitHeight

                cursorShape: Qt.PointingHandCursor
                readonly property bool active: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId)

                onPressed: Hyprland.dispatch(`workspace ${wsId}`)

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    Text {
                        id: ws
                        anchors.centerIn: parent
                        text: wsId
                        font.pixelSize: T.Config.fontSizeNormal
                        font.weight: active ? Font.Bold : Font.Normal
                        font.family: T.Config.fontFamily
                        color: active ? T.Config.active : T.Config.inactive
                    }
                }
            }
        }
    }
}
