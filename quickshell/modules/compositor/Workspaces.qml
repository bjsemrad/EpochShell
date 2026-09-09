import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.theme as T
import qs.services as S

// The bar's workspace strip, for whichever compositor is running.
//
// Everything it renders comes from CompositorService's normalized state, so there is one widget
// rather than one per compositor. Window icons are shown when Config.workspaceIcons is set.
Rectangle {
    id: workspaceFrame
    radius: 20
    color: "transparent"
    Layout.alignment: Qt.AlignVCenter

    property int padding: 7
    property int verticalPadding: 10

    implicitHeight: inner.implicitHeight + verticalPadding
    implicitWidth: inner.implicitWidth + padding * 2

    // Nothing to show until EpochOxide has answered; the strip collapses rather than holding
    // stale state from a compositor that may no longer be running.
    visible: S.CompositorService.workspaces.length > 0

    RowLayout {
        id: inner
        spacing: padding / 2
        anchors.centerIn: parent

        Repeater {
            model: S.CompositorService.workspaces

            delegate: Rectangle {
                id: workspaceWrapper
                required property var modelData

                readonly property string wsId: String(modelData.id)
                readonly property string wsName: String(modelData.name)
                readonly property bool active: modelData.active === true
                readonly property bool urgent: modelData.urgent === true
                readonly property var windows: S.CompositorService.windowsForWorkspace(wsName)
                readonly property bool occupied: windows.length > 0

                // An empty, inactive workspace is not worth a slot in the bar.
                visible: !T.Config.hideInactiveWorkspaces || active || occupied
                Layout.preferredWidth: visible ? innerRow.implicitWidth + padding * 2 : 0
                Layout.preferredHeight: visible ? innerRow.implicitHeight + verticalPadding / 2 : 0

                color: active ? T.Config.surfaceContainer : mwrap.containsMouse ? T.Config.activeSelection : "transparent"
                radius: 10

                WrapperMouseArea {
                    id: mwrap
                    anchors.centerIn: parent
                    implicitWidth: visible ? innerRow.implicitWidth : 0
                    implicitHeight: visible ? innerRow.implicitHeight : 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed: S.CompositorService.focusWorkspace(workspaceWrapper.wsId)

                    RowLayout {
                        id: innerRow
                        anchors.fill: parent
                        spacing: 5

                        Text {
                            text: workspaceWrapper.wsName
                            font.pixelSize: T.Config.barIconSize
                            font.weight: workspaceWrapper.active ? Font.Bold : Font.Normal
                            font.family: T.Config.fontFamily
                            color: workspaceWrapper.urgent ? T.Config.red : workspaceWrapper.active ? T.Config.active : T.Config.inactive
                        }

                        Repeater {
                            model: T.Config.workspaceIcons ? workspaceWrapper.windows : []

                            delegate: IconImage {
                                required property var modelData

                                implicitWidth: T.Config.barIconSize
                                implicitHeight: T.Config.barIconSize
                                source: S.CompositorService.getDesktopIcon(S.CompositorService.getDesktopEntry(String(modelData.app_id || "")))
                                // The focused window is the one the user is looking at; the rest
                                // of a workspace's windows are dimmed.
                                opacity: modelData.focused ? 1.0 : 0.35
                            }
                        }
                    }
                }
            }
        }
    }
}
