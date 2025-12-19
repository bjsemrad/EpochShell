import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Io
import qs.theme as T
import qs.popups
import qs.modules
import qs.modules.audio
import qs.modules.battery
import qs.modules.bluetooth
import qs.modules.ethernet
import qs.modules.wifi
import qs.modules.tailscale
import qs.modules.systemtray
import qs.services as S

Scope {
    id: bar
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            anchors {
                top: true
                left: true
                right: true
            }
            color: T.Config.background
            implicitHeight: T.Config.barHeight

            RowLayout {
                id: leftSide
                spacing: 10
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                children: [
                    BarFill {},
                    ApplicationLauncher {},
                    BarFill {}
                ]
            }

            RowLayout {
                id: centerSide
                spacing: 10

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    centerIn: parent
                }
                readonly property int available: parent.width

                implicitWidth: available
                children: [
                    BarFill {},
                    NiriWorkspaces {
                        visible: S.CompositorService.isNiri
                    },
                    HyprlandWorkspacesIcons {
                        visible: S.CompositorService.isHyprland && T.Config.workspaceIcons
                    },
                    HyprlandWorkspaces {
                        visible: S.CompositorService.isHyprland && !T.Config.workspaceIcons
                    },
                    BarFill {}
                ]
            }

            RowLayout {
                id: rightSide
                spacing: 10
                Layout.alignment: Qt.AlignVCenter

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }

                Loader {
                    id: normalLoader
                    active: T.Config.showIndividualIcons

                    sourceComponent: IndividualBarRight {}
                }

                Loader {
                    id: specialLoader
                    active: T.Config.showIndividualIcons === false

                    sourceComponent: GroupedBarRight {}
                }
            }
        }
    }
}
