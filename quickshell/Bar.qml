import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.theme as T
import qs.popups
import qs.modules
import qs.modules.audio
import qs.modules.compositor
import qs.services as S

Scope {
    id: bar
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            anchors {
                top: true
                left: true
                right: true
            }
            color: T.Config.background
            implicitHeight: T.Config.barHeight

            // Stay awake, at the compositor's level. The backend holds a logind inhibitor, which
            // is what hypridle and systemd watch; this is the belt to that pair of braces, because
            // a Wayland idle-inhibit stops the compositor reporting idle at all -- and it has to
            // live here, since the protocol inhibits against a surface and the daemon has none.
            IdleInhibitor {
                window: barWindow
                enabled: S.StayAwake.enabled
            }

            Flickable {
                id: leftSide
                width: Math.min(leftContent.implicitWidth, parent.width * T.Config.workspaceStripMaxWidthRatio)
                contentWidth: leftContent.implicitWidth
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentWidth > width
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                RowLayout {
                    id: leftContent
                    height: parent.height
                    spacing: T.Config.barModuleSpacing

                    BarFill {}
                    ApplicationLauncher {}
                    Workspaces {}
                    BarFill {}
                }
            }

            RowLayout {
                id: centerSide
                spacing: T.Config.barModuleSpacing

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    centerIn: parent
                }
                readonly property int available: parent.width

                implicitWidth: available
                children: [
                    BarFill {},
                    MediaIndicator {
                        id: mediaIndicator
                        popup: mediaPanel
                    },
                    ClickableClock {
                        id: clock
                        popup: calendarPanel
                    },
                    Weather {
                        id: weather
                        popup: weatherPanel
                    },
                    BarFill {}
                ]
            }

            RowLayout {
                id: rightSide
                spacing: T.Config.barModuleSpacing
                Layout.alignment: Qt.AlignVCenter

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: T.Config.barModuleSpacing
                }

                IndividualBarRight {}
            }

            CalendarPanel {
                id: calendarPanel
                trigger: clock
            }

            WeatherPanel {
                id: weatherPanel
                trigger: weather
            }

            MediaPanel {
                id: mediaPanel
                trigger: mediaIndicator
            }
        }
    }
}
