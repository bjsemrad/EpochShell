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
        spacing: padding
        anchors.centerIn: parent

        Repeater {
            model: S.NiriService.workspaces

            delegate: Rectangle {
                id: workspaceWrapper
                required property var modelData
                readonly property int wsId: modelData.idx
                readonly property bool active: modelData.isFocused
                color: active ? T.Config.surfaceContainer : mwrap.containsMouse ? T.Config.activeSelection : "transparent"
                Layout.preferredWidth: innerRow.implicitWidth + padding * 3
                Layout.preferredHeight: innerRow.implicitHeight + padding / 2
                visible: modelData.isActive || modelData.isOccupied
                radius: 10
                // border.width: 1
                // border.color: active ? T.Config.accentLightShade : "transparent"

                WrapperMouseArea {
                    id: mwrap
                    anchors.centerIn: parent
                    implicitWidth: visible ? innerRow.implicitWidth : 0
                    implicitHeight: visible ? innerRow.implicitHeight : 0
                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor
                    property var windows: []

                    onPressed: S.NiriService.switchToWorkspace(modelData)

                    function rebuildWindows() {
                        windows = S.NiriService.getWindowsForWorkspace(wsId) || [];
                    }

                    Component.onCompleted: rebuildWindows()

                    Connections {
                        target: S.NiriService
                        function onWindowListChanged() {
                            Qt.callLater(mwrap.rebuildWindows);
                        }
                        function onActiveWindowChanged() {
                            Qt.callLater(mwrap.rebuildWindows);
                        }
                        function onWorkspaceChanged() {
                            Qt.callLater(mwrap.rebuildWindows);
                        }
                    }

                    RowLayout {
                        id: innerRow
                        anchors.fill: parent
                        spacing: 5

                        Text {
                            id: ws
                            text: wsId
                            font.pixelSize: 16
                            font.weight: active ? Font.Bold : Font.Normal
                            font.family: T.Config.fontFamily
                            color: active ? T.Config.active : T.Config.inactive
                        }
                        Text {
                            text: "|"
                            font.pixelSize: 16
                            font.weight: Font.Normal
                            font.family: T.Config.fontFamily
                            color: T.Config.inactive
                            visible: mwrap.windows.length > 0
                        }
                        Repeater {
                            model: mwrap.windows
                            delegate: RowLayout {
                                spacing: 5
                                property var entry: S.CompositorService.getDesktopEntry(modelData.appId)
                                IconImage {
                                    width: 20
                                    height: 20

                                    source: S.CompositorService.getDesktopIcon(entry)
                                    opacity: modelData.isFocused ? 1.0 : 0.35
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
