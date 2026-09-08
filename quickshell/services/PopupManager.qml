pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property var openPopups: []

    // Named registry backing the "panel" IPC target. Bar.qml builds its panels under
    // Variants { model: Quickshell.screens }, so one name maps to one popup per screen; entries
    // is a flat [{ name, popup }] list rather than a name->popup map so the duplicates survive
    // registration and a screen going away can drop just its own entry.
    property var entries: []

    readonly property var panelNames: {
        const seen = [];
        for (const entry of root.entries) {
            if (seen.indexOf(entry.name) === -1) seen.push(entry.name);
        }
        return seen.sort();
    }

    // The launcher is a single full-screen overlay owned by the shell root rather than one per
    // bar, so it is held on its own instead of in the per-screen entries list.
    property var launcher: null

    function register(popup, name) {
        if (openPopups.indexOf(popup) === -1) {
            openPopups.push(popup);
        }
        if (!name || name.length === 0) return;
        for (const entry of root.entries) {
            if (entry.popup === popup) return;
        }
        root.entries = root.entries.concat([{ name: String(name), popup: popup }]);
    }

    function unregister(popup) {
        const kept = [];
        for (const p of root.openPopups) {
            if (p !== popup) kept.push(p);
        }
        root.openPopups = kept;
        root.entries = root.entries.filter(entry => entry.popup !== popup);
    }

    function registerLauncher(overlay) {
        root.launcher = overlay;
    }

    function popupsFor(name) {
        return root.entries.filter(entry => entry.name === name).map(entry => entry.popup);
    }

    // Every screen registers under the same name; the first one registered is the primary bar's,
    // which is where a panel opened from a keybinding should show up.
    function panelFor(name) {
        const list = root.popupsFor(name);
        return list.length > 0 ? list[0] : null;
    }

    function hasPanel(name) {
        return root.panelFor(name) !== null;
    }

    function isPanelOpen(name) {
        const popup = root.panelFor(name);
        return popup !== null && popup.open;
    }

    function openPanel(name) {
        const popup = root.panelFor(name);
        if (!popup) return false;
        root.closeOthers(popup);
        popup.showPanel();
        return true;
    }

    function closePanel(name) {
        const popup = root.panelFor(name);
        if (!popup) return false;
        popup.hidePanel();
        return true;
    }

    function togglePanel(name) {
        const popup = root.panelFor(name);
        if (!popup) return false;
        if (popup.open) {
            popup.hidePanel();
        } else {
            root.closeOthers(popup);
            popup.showPanel();
        }
        return true;
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
            }
        }
    }
}
