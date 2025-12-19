import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.ethernet
import qs.commonwidgets
import qs.theme as T

ExpandingOverview {
    EthernetHeader {}
    ComponentSplitter {}
    EthernetConnectedNetwork {}
    ComponentSpacer {}
}
