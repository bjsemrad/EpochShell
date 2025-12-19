import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.theme as T
import qs.services as S
import qs.commonwidgets

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    Layout.topMargin: 5

    required property string headerText
    required property bool checkedValue
    property bool enableToggle: true

    function handleToggled(checked) {
        console.log("Missing Implementation");
    }

    function settingsClick() {
        console.log("Missing Implementation");
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 30
        color: "transparent"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: headerText
            color: T.Config.surfaceText
            font.bold: true
            font.pointSize: 13
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        RoundedSwitch {
            id: rSwitch
            visible: enableToggle
            Layout.alignment: Qt.AlignVCenter
            checked: checkedValue
            onToggled: {
                handleToggled(rSwitch.checked);
            }
        }
        PanelHeaderIcon {
            id: settings
            iconText: ""
            function onClick() {
                settingsClick();
            }
        }
    }
}
