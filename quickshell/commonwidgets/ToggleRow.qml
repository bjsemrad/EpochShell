import QtQuick
import QtQuick.Layouts
import qs.theme as T

// One switched option in a panel: a label, an optional hint under it, and a switch.
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
    // False shows the row but refuses the switch: the hint says why it cannot be used.
    property bool enableToggle: true

    function handleToggled(checked) {
        console.log("Missing Implementation");
    }

    // Inset on the right so the switch is not flush against the popup's border. The action rows
    // above carry systemActionMargin on their left, and a switch hard against the edge next to
    // them reads as a layout mistake.
    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: T.Config.systemActionSpacing
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
            opacity: root.enableToggle ? 1 : 0.4
            onToggled: {
                if (!root.enableToggle) {
                    optionSwitch.checked = root.checkedValue;
                    return;
                }
                root.handleToggled(optionSwitch.checked);
            }
        }
    }
}
