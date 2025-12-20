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
            model: Hyprland.workspaces.values
            delegate: Rectangle {
                id: workspaceWrapper
                required property var modelData
                readonly property int wsId: modelData.id
                readonly property bool active: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId)
                property var sortedWindows: {
                    const arr = [];
                    const m = modelData.toplevels.values;
                    for (let i = 0; i < m.length; i++)
                        arr.push(m[i]);

                    arr.sort((a, b) => {
                        if (a.lastIpcObject?.at?.[0] !== b.lastIpcObject?.at?.[0]) {
                            return a.lastIpcObject?.at?.[0] - b.lastIpcObject?.at?.[0];
                        }
                        return a.lastIpcObject?.at?.[1] - b.lastIpcObject?.at?.[1];
                    });

                    return arr;
                }
                color: active ? T.Config.surfaceContainer : mwrap.containsMouse ? T.Config.activeSelection : "transparent"
                Layout.preferredWidth: innerRow.implicitWidth + padding * 3
                Layout.preferredHeight: innerRow.implicitHeight + padding / 2
                visible: true
                radius: 10

                Connections {
                    target: Hyprland
                    function onActiveToplevelChanged() {
                        Hyprland.refreshToplevels();
                        Qt.callLater(() => Qt.callLater(() => { /* read extra ticks */ }));
                        Hyprland.refreshWorkspaces();
                        Qt.callLater(() => Qt.callLater(() => { /* read */ }));
                    }
                }

                WrapperMouseArea {
                    id: mwrap
                    anchors.centerIn: parent
                    implicitWidth: visible ? innerRow.implicitWidth : 0
                    implicitHeight: visible ? innerRow.implicitHeight : 0
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed: Hyprland.dispatch(`workspace ${wsId}`)

                    RowLayout {
                        id: innerRow
                        anchors.fill: parent
                        spacing: 5

                        Text {
                            id: ws
                            text: wsId
                            font.pixelSize: T.Config.fontSizeMedium
                            font.weight: active ? Font.Bold : Font.Normal
                            font.family: T.Config.fontFamily
                            color: active ? T.Config.active : T.Config.inactive
                        }
                        Text {
                            text: "|"
                            font.pixelSize: T.Config.fontSizeMedium
                            font.weight: Font.Normal
                            font.family: T.Config.fontFamily
                            color: T.Config.inactive
                            visible: modelData.toplevels.values.length > 0
                        }
                        Repeater {
                            model: workspaceWrapper.sortedWindows
                            delegate: RowLayout {
                                required property var modelData
                                spacing: 5

                                IconImage {
                                    width: 20
                                    height: 20

                                    source: {
                                        const keys = [modelData?.lastIpcObject?.class, modelData?.lastIpcObject?.initialClass, modelData?.wayland?.appId].filter(k => !!k);
                                        let entry = null;
                                        for (let i = 0; i < keys.length && !entry; i++) {
                                            const k = String(keys[i]);
                                            entry = S.CompositorService.getDesktopEntry(k);
                                            if (entry) {
                                                break;
                                            }
                                        }

                                        return S.CompositorService.getDesktopIcon(entry);
                                    }
                                    opacity: modelData.wayland?.activated ? 1.0 : 0.35
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
