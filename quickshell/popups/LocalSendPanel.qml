import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.commonwidgets
import qs.modules.localsend
import qs.theme as T
import qs.services as S

HoverPopupWindow {
    id: localSendPopup
    trigger: trigger
    popupWidth: T.Config.localsendPopupWidth

    // Discovery is a request/response burst, not a subscription, so it runs when the panel opens
    // rather than on a timer nobody is watching.
    onVisibleChanged: {
        if (visible) {
            S.LocalSend.refresh();
            S.PopupManager.closeOthers(localSendPopup);
        }
    }

    Component.onDestruction: S.PopupManager.unregister(localSendPopup)
    Component.onCompleted: S.PopupManager.register(localSendPopup, "localsend")

    LocalSendOnOff {}
    LocalSendStatus {}
    ComponentSplitter {}
    LocalSendReceive {}
    ComponentSplitter {}
    LocalSendFileDrop { popupWindow: localSendPopup }
    ComponentSplitter {}
    LocalSendDevices {}
    ComponentSpacer { bottomMargin: 6; Layout.preferredHeight: 1 }
}
