import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.commonwidgets
import qs.services as S
import qs.theme as T

HoverPopupWindow {
    id: notificationPopup
    trigger: trigger
    popupWidth: T.Config.systemTrayPopupWidth + 120

    property int scrollBarPadding: 14

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(notificationPopup);
            S.Notifications.markRead();
        }
    }

    Component.onCompleted: S.PopupManager.register(notificationPopup)

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: T.Config.settingsHeaderHeight
        spacing: T.Config.layoutMarginSmall

        Text {
            text: "Notifications"
            color: T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
            font.bold: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            radius: T.Config.popupRadius
            color: dndMouseArea.containsMouse ? T.Config.activeSelection : S.Notifications.doNotDisturb ? T.Config.surfaceContainerHigh : "transparent"
            border.width: 1
            border.color: S.Notifications.doNotDisturb ? T.Config.accent : T.Config.outline
            implicitWidth: dndText.implicitWidth + T.Config.popupPadding * 2
            implicitHeight: T.Config.settingsHeaderHeight
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: dndText
                anchors.centerIn: parent
                text: S.Notifications.doNotDisturb ? "DND On" : "DND Off"
                color: S.Notifications.doNotDisturb ? T.Config.accent : T.Config.surfaceText
            font.pixelSize: T.Config.fontSizeLarge
                font.family: T.Config.fontFamily
            }

            MouseArea {
                id: dndMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: S.Notifications.toggleDoNotDisturb()
            }
        }

        PanelHeaderIcon {
            iconText: "󰎟"
            function onClick() {
                S.Notifications.clearHistory();
            }
        }
    }

    ComponentSplitter {}

    Text {
        visible: S.Notifications.historyModel.count === 0
        text: "No notifications"
        color: T.Config.inactive
        font.pixelSize: T.Config.fontSizeNormal
        font.family: T.Config.fontFamily
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: T.Config.popupPadding
        Layout.bottomMargin: T.Config.popupPadding
    }

    ListView {
        id: notificationList
        visible: S.Notifications.historyModel.count > 0
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, Screen.height * 0.75)
        clip: true
        model: S.Notifications.historyModel
        spacing: T.Config.popupLayoutSpacing
        boundsBehavior: Flickable.StopAtBounds

        footer: Item {
            width: notificationList.width
            height: T.Config.popupPadding * 2
        }

        delegate: Item {
            id: historySlot
            required property int notificationId
            required property string appName
            required property string appIcon
            required property string windowClass
            required property string summary
            required property string body
            required property string image
            required property int urgency
            required property int index

            width: notificationList.width - notificationPopup.scrollBarPadding
            height: card.implicitHeight

            NotificationCard {
                id: card
                width: parent.width
                appName: historySlot.appName
                appIcon: historySlot.appIcon
                summary: historySlot.summary
                body: historySlot.body
                image: historySlot.image
                urgency: historySlot.urgency
                closeVisible: true
                onClicked: S.Notifications.focusFromHistory(historySlot.notificationId, historySlot.appName, historySlot.index, historySlot.windowClass)
                onDismissRequested: S.Notifications.dismissHistory(historySlot.index)
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: notificationList.contentHeight > notificationList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            contentItem: Rectangle {
                implicitWidth: 3
                radius: 3
                color: T.Config.surfaceText
            }
        }
    }

    ComponentSpacer { bottomMargin: 6 }
}
