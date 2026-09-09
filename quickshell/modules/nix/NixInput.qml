import QtQuick
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

// One flake input that can move, and where it would move to.
Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight + 4

    required property string name
    required property string source
    required property string currentRev
    required property string latestRev

    // Left margin to line up with the action rows below, right margin so an elided source string
    // stops short of the popup's border rather than running into it.
    ColumnLayout {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: T.Config.systemActionSpacing
        anchors.rightMargin: T.Config.systemActionSpacing
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: root.name
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeNormal
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: S.NixUpdates.shortRev(root.currentRev) + " → " + S.NixUpdates.shortRev(root.latestRev) + "   " + root.source
            color: T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
