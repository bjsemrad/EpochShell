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
    visible: S.CompositorService.isNiri
    Row {
        id: inner
        anchors.centerIn: parent
        height: parent.height
        spacing: 5
        Text {
            text: S.NiriService.focusedWindowIndex !== -1 ? S.NiriService.windows[S.NiriService.focusedWindowIndex].title : ""
            font.pixelSize: T.Config.fontSizeNormal
            anchors.verticalCenter: parent.verticalCenter
            color: T.Config.surfaceText
        }
    }
    Component.onCompleted: {
        Hyprland.refreshToplevels();
    }
}
