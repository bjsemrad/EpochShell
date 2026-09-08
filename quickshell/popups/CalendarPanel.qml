import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.commonwidgets
import qs.services as S
import qs.theme as T

HoverPopupWindow {
    id: popup
    trigger: trigger
    popupWidth: 360

    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    readonly property var labelLocale: Qt.locale("en_US")

    function showPanel() {
        today = new Date();
        open = true;
        visible = true;
    }

    function hidePanel() {
        open = false;
        visible = false;
        popupHover = false;
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstVisibleDate() {
        const first = new Date(viewYear, viewMonth, 1);
        const offset = first.getDay();
        return new Date(viewYear, viewMonth, 1 - offset);
    }

    function cellDate(index) {
        const start = firstVisibleDate();
        return new Date(start.getFullYear(), start.getMonth(), start.getDate() + index);
    }

    function sameDay(left, right) {
        return left.getFullYear() === right.getFullYear() && left.getMonth() === right.getMonth() && left.getDate() === right.getDate();
    }

    function moveMonth(delta) {
        const next = new Date(viewYear, viewMonth + delta, 1);
        viewYear = next.getFullYear();
        viewMonth = next.getMonth();
    }

    function goToToday() {
        today = new Date();
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }

    Component.onDestruction: S.PopupManager.unregister(popup)
    Component.onCompleted: {
        S.PopupManager.register(popup, "calendar");
    }

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(popup);
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: Qt.formatDate(today, "dddd, MMMM d")
                color: T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeMedium
                font.bold: true
                Layout.fillWidth: true
            }

            Text {
                text: "Today"
                color: todayArea.containsMouse ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeSubtext

                MouseArea {
                    id: todayArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.goToToday()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "<"
                color: previousArea.containsMouse ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeXLarge

                MouseArea {
                    id: previousArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.moveMonth(-1)
                }
            }

            Text {
                text: Qt.formatDate(new Date(viewYear, viewMonth, 1), "MMMM yyyy")
                color: T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeNormal
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: ">"
                color: nextArea.containsMouse ? T.Config.accent : T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeXLarge

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.moveMonth(1)
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 6
            columnSpacing: 6

            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]

                delegate: Text {
                    text: modelData
                    color: T.Config.inactive
                    font.pixelSize: T.Config.fontSizeSubtext
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }

            Repeater {
                model: 42

                delegate: Rectangle {
                    property date day: popup.cellDate(index)
                    property bool currentMonth: day.getMonth() === popup.viewMonth
                    property bool currentDay: popup.sameDay(day, popup.today)

                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 999
                    color: currentDay ? T.Config.accentLightShade : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: day.getDate()
                        color: currentDay ? T.Config.accent : currentMonth ? T.Config.surfaceText : T.Config.inactive
                        font.pixelSize: T.Config.fontSizeNormal
                        font.bold: currentDay
                    }
                }
            }
        }
    }
}
