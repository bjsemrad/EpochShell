import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme as T

Rectangle {
    id: clock
    Layout.preferredWidth: clockText.implicitWidth
    Layout.rightMargin: 10

    SystemClock {
        id: sysclk
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        text: Qt.formatDateTime(sysclk.date, "ddd hh:mm AP")
        color: T.Config.surfaceText
        font {
            pointSize: T.Config.fontSizeSubtext
            family: T.Config.fontFamily
        }
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
}
