import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.theme as T

// One switched option in the capture panel: a label, a hint, and a switch.
//
// SettingsToggleHeader is the bold section header with a settings gear; these sit under it as
// ordinary rows, so they are their own small widget rather than a header pretending not to be one.
Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: T.Config.settingsHeaderHeight

    required property string label
    required property bool checkedValue
    property string hint: ""

    function handleToggled(checked) {
        console.log("Missing Implementation");
    }

    RowLayout {
        anchors.fill: parent
        spacing: T.Config.layoutMarginSmall

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                text: root.label
                color: T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeNormal
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                visible: root.hint.length > 0
                text: root.hint
                color: T.Config.outline
                font.pixelSize: T.Config.fontSizeSubtext
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        RoundedSwitch {
            id: optionSwitch
            Layout.alignment: Qt.AlignVCenter
            checked: root.checkedValue
            onToggled: root.handleToggled(optionSwitch.checked)
        }
    }
}
