import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.commonwidgets
import qs.modules
import qs.theme as T
import qs.services as S

Item {
    id: trayContainer
    Layout.fillWidth: true
    Layout.preferredHeight: iconRow.implicitHeight

    RowLayout {
        id: iconRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: S.SystemTray.trayItems

            delegate: Item {
                id: delegateRoot
                property var trayItem: modelData
                property string iconSource: {
                    let icon = trayItem && trayItem.icon;
                    if (typeof icon === 'string' || icon instanceof String) {
                        if (icon === "") {
                            return "";
                        }
                        if (icon.includes("?path=")) {
                            const split = icon.split("?path=");
                            if (split.length !== 2) {
                                return icon;
                            }
                            const name = split[0];
                            const path = split[1];
                            let fileName = name.substring(name.lastIndexOf("/") + 1);
                            return `file://${path}/${fileName}`;
                        }
                        if (icon.startsWith("/") && !icon.startsWith("file://")) {
                            return `file://${icon}`;
                        }
                        return icon;
                    }
                    return "";
                }

                Layout.preferredWidth: 30
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: visualContent
                    width: 30
                    height: 30
                    // Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    radius: 15
                    color: trayItemArea.containsMouse ? T.Config.activeSelection : "transparent"

                    IconImage {
                        id: iconImg
                        width: 18
                        height: 18
                        source: delegateRoot.iconSource
                        asynchronous: true
                        smooth: true
                        mipmap: true
                        visible: status === Image.Ready
                    }

                    QsMenuAnchor {
                        id: menu
                        menu: trayItem.menu
                        onVisibleChanged: {
                            systemTrayPopup.stopHide = menu.visible;
                        }

                        anchor {
                            item: iconImg
                            edges: Edges.Left | Edges.Bottom
                            gravity: Edges.Right | Edges.Bottom
                            adjustment: PopupAdjustment.FlipX
                        }
                    }

                    Text {
                        visible: !iconImg.visible
                        text: {
                            const itemId = trayItem?.id || "";
                            if (!itemId) {
                                return "?";
                            }
                            return itemId.charAt(0).toUpperCase();
                        }
                        font.pixelSize: 10
                        color: T.Config.surfaceText
                    }
                }

                MouseArea {
                    id: trayItemArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        console.log("HERE");
                        if (mouse.button === Qt.LeftButton && !delegateRoot.trayItem.onlyMenu) {
                            delegateRoot.trayItem.activate();
                            return;
                        }

                        if (mouse.button === Qt.RightButton && !delegateRoot.trayItem.onlyMenu) {
                            menu.open();
                            return;
                        }
                    }
                }
            }
        }
    }
}
