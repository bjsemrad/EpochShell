import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.services as S
import qs.theme as T

HoverPopupWindow {
    id: popup
    trigger: trigger
    popupWidth: 480

    function showPanel() {
        if (trigger && typeof trigger.refresh === "function") {
            trigger.refresh();
        }
        open = true;
        visible = true;
    }

    function hidePanel() {
        open = false;
        visible = false;
        popupHover = false;
    }

    Component.onDestruction: S.PopupManager.unregister(popup)
    Component.onCompleted: {
        S.PopupManager.register(popup, "weather");
    }

    onVisibleChanged: {
        if (visible) {
            S.PopupManager.closeOthers(popup);
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 18

            Text {
                text: trigger ? trigger.weatherIcon : ""
                color: T.Config.accent
                font.pixelSize: 44
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: trigger && trigger.location ? trigger.location : "Weather"
                    color: T.Config.surfaceText
                    font.pixelSize: T.Config.fontSizeMedium
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: trigger ? trigger.condition : "Loading"
                    color: T.Config.inactive
                    font.pixelSize: T.Config.fontSizeSubtext
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Text {
                text: trigger ? trigger.temperature : ""
                color: T.Config.surfaceText
                font.pixelSize: T.Config.fontSizeXLarge
                font.bold: true
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 10
            rowSpacing: 10

            WeatherStat {
                label: "Feels"
                value: trigger ? trigger.feelsLike : ""
            }

            WeatherStat {
                label: "Humidity"
                value: trigger ? trigger.humidity : ""
            }

            WeatherStat {
                label: "Wind"
                value: trigger ? trigger.wind : ""
            }
        }

        Rectangle {
            visible: trigger && trigger.forecast.length > 1
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: T.Config.surfaceText
            opacity: 0.12
        }

        Item {
            visible: trigger && trigger.forecast.length > 1
            Layout.fillWidth: true
            Layout.preferredHeight: forecastRow.implicitHeight

            RowLayout {
                id: forecastRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 36

                Repeater {
                    model: trigger ? trigger.forecast.slice(1) : []

                    delegate: RowLayout {
                        spacing: 10

                        Text {
                            text: modelData.icon
                            color: T.Config.surfaceText
                            font.pixelSize: T.Config.fontSizeXLarge
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: Qt.formatDate(new Date(modelData.date + "T00:00:00"), "ddd").toUpperCase()
                                color: T.Config.inactive
                                font.pixelSize: T.Config.fontSizeSubtext
                                font.letterSpacing: 1
                            }

                            RowLayout {
                                spacing: 6

                                Text {
                                    text: modelData.high
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.fontSizeNormal
                                }

                                Text {
                                    text: modelData.low
                                    color: T.Config.inactive
                                    font.pixelSize: T.Config.fontSizeNormal
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: 8
        }
    }
}
