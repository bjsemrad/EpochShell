import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.theme as T

RowLayout {
    id: workspaces
    spacing: 6
    Layout.alignment: Qt.AlignVCenter

    Repeater {
        model: Hyprland.workspaces.values

        delegate: WrapperMouseArea {
            required property var modelData
            readonly property int wsId: modelData.id

            implicitWidth: 30
            implicitHeight: 22

            readonly property bool active: (
                Hyprland.focusedWorkspace
                && Hyprland.focusedWorkspace.id === wsId
            )

            onPressed: Hyprland.dispatch(`workspace ${wsId}`)

            Rectangle {
                anchors.fill: parent
                color: T.Config.bg

                Text {
                    anchors.centerIn: parent
                    text: wsId
                    font.pixelSize: 16
                    font.weight: active ? Font.Bold : Font.Normal
                    font.family: T.Config.fontFamily
                    color: active ? T.Config.active  : T.Config.inactive
                }
            }
        }
    }
}
