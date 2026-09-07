import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.commonwidgets
import qs.services as S
import qs.theme as T

HoverPopupWindow {
    id: homeAssistantPopup
    trigger: trigger
    popupWidth: T.Config.homeAssistantPopupWidth

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(homeAssistantPopup);
            S.HomeAssistant.refresh();
        }
    }

    Component.onCompleted: S.PopupManager.register(homeAssistantPopup)

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Home Assistant"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        PanelHeaderIcon {
            iconText: "󰑓"
            function onClick() {
                S.HomeAssistant.refresh();
            }
        }
    }

    ComponentSplitter {}

    Text {
        Layout.fillWidth: true
        text: S.HomeAssistant.statusText
        color: S.HomeAssistant.connected ? T.Config.inactive : T.Config.orange
        font.pixelSize: T.Config.fontSizeSubtext
        elide: Text.ElideRight
    }

    Text {
        visible: !S.HomeAssistant.configured
        Layout.fillWidth: true
        text: "Create ~/.config/epochshell-hass.json with baseUrl, token, and favorites."
        color: T.Config.inactive
        font.pixelSize: T.Config.fontSizeSubtext
        wrapMode: Text.WordWrap
    }

    ListView {
        id: entityList
        visible: S.HomeAssistant.rows.count > 0
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, Screen.height * 0.55)
        clip: true
        model: S.HomeAssistant.rows
        spacing: T.Config.popupLayoutSpacing
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row
            required property string entityId
            required property string name
            required property string state
            required property string icon
            required property bool controllable

            width: entityList.width - 12
            height: 42
            radius: T.Config.cardRadius
            color: rowHover.hovered ? T.Config.surfaceContainerHigh : T.Config.surface
            border.width: 1
            border.color: T.Config.outline

            HoverHandler { id: rowHover }

            RowLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: T.Config.cardSpacing

                Text {
                    text: row.icon
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeLarge
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: row.name
                        color: T.Config.surfaceText
                        font.pixelSize: T.Config.fontSizeNormal
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: row.state
                        color: T.Config.inactive
                        font.pixelSize: T.Config.fontSizeSubtext
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    visible: row.controllable
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 26
                    radius: T.Config.roundRadius
                    color: toggleMouse.containsMouse ? T.Config.accentLightShade : T.Config.surfaceContainer
                    border.width: 1
                    border.color: T.Config.outline

                    Text {
                        anchors.centerIn: parent
                        text: row.entityId.indexOf("scene.") === 0 || row.entityId.indexOf("script.") === 0 ? "Run" : "Toggle"
                        color: T.Config.surfaceText
                        font.pixelSize: T.Config.fontSizeSubtext
                    }

                    MouseArea {
                        id: toggleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !S.HomeAssistant.loading
                        onClicked: mouse => {
                            mouse.accepted = true;
                            S.HomeAssistant.toggleEntity(row.entityId);
                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: entityList.contentHeight > entityList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            contentItem: Rectangle {
                implicitWidth: 3
                radius: 3
                color: T.Config.surfaceText
                opacity: 0.7
            }
        }
    }

    ComponentSpacer { bottomMargin: 6 }
}
