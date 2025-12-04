// modules/Workspaces.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import "../theme" as T

Row {
    id: workspaces
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: Hyprland.workspaces.values

        delegate: WrapperMouseArea {
            required property var modelData   // workspace object from hyprland
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

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            workspaces.forceLayout()
        }
    }

}

