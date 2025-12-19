pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property color accent: blue
    property color accentLightShade: Qt.rgba(Qt.color(accent).r, Qt.color(accent).g, Qt.color(accent).b, 0.10)
    property color inactive: Qt.rgba(Qt.color(surfaceText).r, Qt.color(surfaceText).g, Qt.color(surfaceText).b, 0.75)
    property color active: surfaceText
    property color activeSelection: surfaceContainerHigh //Qt.rgba(Qt.color(surfaceContainerHigh).r, Qt.color(surfaceContainerHigh).g, Qt.color(surfaceContainerHigh).b, 0.25)

    property color background: "#0e1013"
    property color surface: "#1f2329"
    property color surfaceVariant: "#323641"
    property color surfaceContainer: "#1f2329"
    property color surfaceContainerHigh: "#282c34" //"#272a2f"
    property color surfaceContainerHighest: "#30363f"
    property color surfaceText: "#a0a8b7"
    property color outline: "#8c9199"

    // ───────────────────────────────────────────────
    //  ACCENT COLORS
    // ───────────────────────────────────────────────
    //
    property color purple: "#bf68d9"
    property color green: "#8ebd6b"
    property color orange: "#cc9057"
    property color blue: "#4fa6ed"
    property color yellow: "#e2b86b"
    property color cyan: "#48b0bd"
    property color red: "#e55561"
    property color bg_blue: "#61afef"
    property color bg_yellow: "#e8c88c"

    /* Misc */
    property string fontFamily: "JetBrainsMono Nerd Font Propo"

    property int networkPopupWidth: 400
    property int tailscalePopupWidth: 600
    property int bluetoothPopupWidth: 400
    property int audioPopupWidth: 550
    property int systemTrayPopupWidth: 300
    property int systemPopupWidth: 300
    property int batteryPopupWidth: 250

    property int tailscalePeersFontSize: 14

    property int selectedBorderWidth: 1
    property int panelBottomMargin: 5

    property bool showIndividualIcons: false

    property int barHeight: 40
    property int cornerRadius: 18

    property bool panelAnimationsEnabled: false
    property bool popupControlCenter: true

    property bool hideInactiveWorkspaces: true
    property bool workspaceIcons: true
}
