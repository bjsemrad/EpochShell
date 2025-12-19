import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.theme as T

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: inner.implicitWidth + 20
    implicitHeight: inner.implicitHeight + 5
    Row {
        id: inner
        anchors.centerIn: parent
        height: parent.height
        spacing: 5
        Text {
            text: Hyprland.activeToplevel?.wayland?.title ?? ""
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            color: T.Config.surfaceText
        }
    }
    Component.onCompleted: {
        Hyprland.refreshToplevels();
    }
}
