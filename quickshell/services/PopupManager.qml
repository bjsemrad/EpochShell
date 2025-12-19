pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var openPopups: []

    function register(popup) {
        if (openPopups.indexOf(popup) === -1) {
            openPopups.push(popup);
        }
    }

    function closeOthers(except) {
        for (let p of openPopups) {
            if (p !== except && p.open) {
                p.hidePanel();
            }
        }
    }

    function closeAll() {
        for (let p of openPopups) {
            if (p.open) {
                p.hidePanel();
                // p.visible = false
            }
        }
    }
}
