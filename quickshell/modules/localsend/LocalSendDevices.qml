import QtQuick
import QtQuick.Layouts
import qs.services as S
import qs.theme as T

// Nearby devices. Clicking one sends the selected file to it.
Item {
    id: section
    Layout.fillWidth: true
    Layout.preferredHeight: contents.implicitHeight
    Layout.bottomMargin: 10

    function iconFor(deviceType) {
        switch (String(deviceType || "").toLowerCase()) {
        case "mobile": return "󰄜";
        case "desktop": return "󰇄";
        case "web": return "󰖟";
        case "headless": return "󰒋";
        case "server": return "󰒋";
        default: return "󰇄";
        }
    }

    ColumnLayout {
        id: contents
        anchors.fill: parent
        spacing: 6

        Text {
            text: "Devices"
            color: T.Config.surfaceText
            font.pixelSize: 13
            Layout.fillWidth: true
        }

        // Nothing found, and not because something is wrong: say what to do about it.
        Text {
            visible: !S.LocalSend.hasDevices && !S.LocalSend.scanning
            text: S.LocalSend.backendError.length > 0
                ? S.LocalSend.backendError
                : "Open LocalSend on another device on this network, then refresh."
            color: S.LocalSend.backendError.length > 0 ? T.Config.red : T.Config.outline
            font.pixelSize: T.Config.fontSizeSubtext
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            visible: S.LocalSend.hasDevices
            color: "transparent"
            clip: true
            radius: T.Config.cardRadius
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(deviceFlick.contentHeight, 260)

            Flickable {
                id: deviceFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: column.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: column
                    width: deviceFlick.width
                    spacing: 6

                    Repeater {
                        model: S.LocalSend.devices

                        delegate: Rectangle {
                            id: row
                            required property var modelData

                            readonly property bool sending: S.LocalSend.sendingFile && S.LocalSend.sendTarget === String(modelData.alias)
                            readonly property bool sendable: S.LocalSend.selectedFile.length > 0 && !S.LocalSend.sendingFile

                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 6
                            color: deviceMouse.containsMouse && sendable ? T.Config.activeSelection : "transparent"

                            RowLayout {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                spacing: 10

                                Text {
                                    text: section.iconFor(row.modelData.device_type)
                                    color: T.Config.surfaceText
                                    font.pixelSize: T.Config.fontSizeMedium
                                    font.family: T.Config.fontFamily
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Layout.fillWidth: true

                                    Text {
                                        text: String(row.modelData.alias || "")
                                        color: T.Config.surfaceText
                                        font.pixelSize: T.Config.fontSizeNormal
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: {
                                            const model = String(row.modelData.device_model || "");
                                            const ip = String(row.modelData.ip || "");
                                            return model.length > 0 ? (model + "  " + ip) : ip;
                                        }
                                        color: T.Config.outline
                                        font.pixelSize: T.Config.fontSizeSubtext
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    // Shows what clicking will do, so a device is never a dead
                                    // target with no explanation.
                                    text: row.sending ? "󰔟" : row.sendable ? "󰅧" : ""
                                    color: T.Config.accent
                                    font.pixelSize: T.Config.fontSizeMedium
                                    font.family: T.Config.fontFamily
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: deviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: row.sendable ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (row.sendable) S.LocalSend.sendFile(row.modelData);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
