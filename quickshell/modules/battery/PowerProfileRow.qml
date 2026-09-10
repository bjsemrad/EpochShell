import QtQuick
import QtQuick.Layouts
import qs.theme as T
import qs.services as S

// What the CPU is doing about power, under the battery level.
//
// Read-only. The profile name is a summary of two knobs, so the raw governor, energy preference
// and turbo state are shown under it -- "Balanced" on its own explains nothing to anyone who has
// opened this panel because the fans are loud.
Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight
    visible: S.PowerProfile.available

    ColumnLayout {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: T.Config.systemActionSpacing
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: T.Config.layoutMarginSmall

            Text {
                text: S.PowerProfile.profileIcon
                color: S.PowerProfile.profile === "performance" ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeMedium
                font.family: T.Config.fontFamily
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: S.PowerProfile.profileLabel
                color: T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeNormal
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Text {
            text: S.PowerProfile.detail
            visible: text.length > 0
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        // Who is deciding. Worth naming: on this machine the answer is not the kernel's default.
        Text {
            text: S.PowerProfile.manager.length > 0 ? ("managed by " + S.PowerProfile.manager) : "unmanaged"
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        // Wear, which no desktop shows and everyone wants: a battery at 94% of the charge it
        // shipped with, after 44 cycles.
        Text {
            visible: S.SystemInfo.batteryHealth > 0
            text: {
                const parts = ["health " + S.SystemInfo.batteryHealth + "%"];
                if (S.SystemInfo.batteryCycles > 0) parts.push(S.SystemInfo.batteryCycles + " cycles");
                return parts.join(" · ");
            }
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
