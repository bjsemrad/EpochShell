pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import qs.theme as T

Singleton {
    id: systray

    readonly property var hiddenTrayIds: ["nm-applet"]
    readonly property var trayItems: {
        return SystemTray.items.values.filter(item => {
            const itemId = item?.id || "";
            return !hiddenTrayIds.includes(itemId.toLowerCase());
        });
    }

    function hasTrayItems() {
        return trayItems.length
    }
}
