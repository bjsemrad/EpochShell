import QtQuick
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

// Header row: what LocalSend can see right now, and a way to look again.
Item {
    id: status
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight

    readonly property string summary: {
        if (S.LocalSend.backendError.length > 0) return S.LocalSend.backendError;
        // Not accepting is a deliberate state, not an error: say so rather than showing a device
        // count that implies transfers can arrive.
        if (!S.LocalSend.receivingAvailable) return "Not accepting transfers";
        if (S.LocalSend.scanning) return "Looking for devices...";
        if (!S.LocalSend.scanned) return "Not searched yet";
        const count = S.LocalSend.devices.length;
        if (count === 0) return "No devices found";
        return count === 1 ? "1 device nearby" : (count + " devices nearby");
    }

    RowLayout {
        id: contents
        anchors.fill: parent
        spacing: T.Config.layoutMarginSmall

        Text {
            text: status.summary
            color: S.LocalSend.backendError.length > 0 ? T.Config.red : T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 24
            radius: 6
            color: refreshMouse.containsMouse ? T.Config.surfaceContainerHigh : "transparent"

            Text {
                anchors.centerIn: parent
                text: "󰑐"
                color: S.LocalSend.scanning ? T.Config.outline : T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeMedium
                font.family: T.Config.fontFamily

                RotationAnimator on rotation {
                    running: S.LocalSend.scanning
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1000
                }
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !S.LocalSend.scanning
                onClicked: S.LocalSend.refresh()
            }
        }
    }
}
