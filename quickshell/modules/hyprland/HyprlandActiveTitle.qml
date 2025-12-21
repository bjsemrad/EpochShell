import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.theme as T
import qs.services as S

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: inner.implicitWidth + T.Config.widthPaddingLarge
    implicitHeight: inner.implicitHeight + T.Config.heightPaddingSmall
    visible: S.CompositorService.isHyprland
    Row {
        id: inner
        anchors.centerIn: parent
        height: parent.height
        spacing: 5
        Text {
            text: {
                if (!S.CompositorService.isHyprland)
                    return "";

                const ws = Hyprland.focusedWorkspace;
                const tl = Hyprland.activeToplevel;

                if (!ws || ws.id === undefined)
                    return "";
                if (!tl || !tl.workspace || tl.workspace.id === undefined)
                    return "";

                return (ws.id === tl.workspace.id) ? (tl.title || "") : "";
            }
            font.pixelSize: T.Config.fontSizeNormal
            anchors.verticalCenter: parent.verticalCenter
            color: T.Config.surfaceText
        }
    }

    Component.onCompleted: {
        Hyprland.refreshToplevels();
    }
}
