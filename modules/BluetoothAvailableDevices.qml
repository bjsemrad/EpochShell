import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../services" as S
import "../theme" as T
import "../commonwidgets"

Rectangle {
    id: bluetoothSection
    width: parent.width
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"

    property bool expanded: false
    implicitHeight: header.height + listContainer.height + 10


    Connections {
        target:  bluetoothPanel
        function onVisibleChanged() {
            if (!bluetoothPanel.visible) {
                bluetoothSection.expanded = false
                S.Bluetooth.stopScan()
            }
        }
    }

    Column {
        anchors.margins: 4
        anchors.fill: parent
        spacing: 15
        Rectangle {
            id: header
            implicitHeight: 20
            width: parent.width
            color: "transparent"
            Row {
                width: parent.width
                spacing: 10
                Text {
                    id: avText
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Available Devices"
                    color: T.Config.fg
                    font.pixelSize: 13
                    Layout.leftMargin: 4
                }

                Row {
                   spacing: 10

                    Rectangle {
                        width: 100
                        height: 20
                        radius: 10
                        color: S.Bluetooth.discovering ? T.Config.green : T.Config.bg2


                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenter: parent.verticalCenter
                            color: S.Bluetooth.discovering ? T.Config.black : T.Config.fg
                            font.bold: true
                            text: S.Bluetooth.discovering ? "Stop Scan" : "Start Scan"
                        }

                        MouseArea {
                            anchors.fill: parent
                             hoverEnabled: true
                             cursorShape: Qt.PointingHandCursor

                           onClicked: function() {
                                if (!S.Bluetooth.adapter) return;
                                if (!S.Bluetooth.discovering) {
                                    S.Bluetooth.scanForDevices()
                                    bluetoothSection.expanded = true

                                } else {
                                    S.Bluetooth.stopScan()
                                }
                            }
                        }
                    }

                    Spinner {
                        id: bluetoothSpinner
                        running: S.Bluetooth.discovering
                    }
                }
            }

        }


        Rectangle {
            id: listContainer
            radius: 6
            color: "#181818"
            clip: true
            border.width: 2
            border.color: T.Config.bg2
            width: parent.width
            implicitHeight: bluetoothSection.expanded
                    ? Math.min(bluetoothList.contentHeight, 300)
                    : 0

            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutQuad
                }
            }

            ListView {
                id: bluetoothList
                anchors.fill: parent
                implicitHeight: Math.min(listContainer.implicitHeight,  100)
                model: S.Bluetooth.devices
                interactive: true

                delegate: Rectangle {
                    width: ListView.view.width*.9
                    implicitHeight: 30
                    radius: 6
                    anchors.margins: 10
                    color: mouseArea.containsMouse ? T.Config.activeSelection : "transparent"

                    Row {
                        anchors.fill: parent
                        width: parent.width
                        anchors.margins: 10
                        spacing: 8


                        Text {
                            text: S.Bluetooth.getDeviceIcon(modelData)
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            color: T.Config.fg
                        }

                        Text {
                            text: modelData.name
                            anchors.verticalCenter: parent.verticalCenter
                            color: "white"
                            font.pixelSize: 13
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !S.Bluetooth.discovering
                        cursorShape: !S.Bluetooth.discovering ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            modelData.trusted = true
                            modelData.connect()
                        }
                    }
                }
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }
            }
        }
    }
}
