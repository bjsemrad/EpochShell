pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isHyprland: false
    property bool isNiri: false

    Component.onCompleted: {
        detectCompositor();
    }

    function detectCompositor() {
        const hyprlandSignature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        const niriSocket = Quickshell.env("NIRI_SOCKET");

        if (niriSocket && niriSocket.length > 0) {
            isHyprland = false;
            isNiri = true;
        } else if (hyprlandSignature && hyprlandSignature.length > 0) {
            isHyprland = true;
            isNiri = false;
        }
    }

    function logout() {
        //TODO
    }

    function iconMatch(field, key) {
        return field.toLowerCase() !== "" && key.toLowerCase().indexOf(field.toLowerCase()) !== -1;
    }

    function getDesktopEntry(app) {
        let entry = DesktopEntries.byId(app) || DesktopEntries.heuristicLookup(app);
        if (!entry) {
            if (app.startsWith("brave-")) {
                const k2 = app.replace(/.com__-Default$/, "").replace(/.com-Default$/, "").replace(/brave-/, "");
                entry = DesktopEntries.heuristicLookup(k2);
            }
            if (app.startsWith("chrome-")) {
                const k2 = app.replace(/.com__-Default$/, "").replace(/.com-Default$/, "").replace(/chrome-/, "");
                entry = DesktopEntries.heuristicLookup(k2);
            }
        }

        //Lookup by basic information
        if (!entry) {
            for (let i = 0; i < DesktopEntries.applications.values.length; i++) {
                const e = DesktopEntries.applications.values[i];
                if (iconMatch(e.name, app) || iconMatch(e.startupClass, app) || iconMatch(e.id, app)) {
                    entry = e;
                    break;
                }
            }
        }
        return entry;
    }

    function getDesktopIcon(entry) {
        if (entry?.icon) {
            const icon = String(entry.icon);

            if (icon.startsWith("/") || icon.startsWith("file:") || icon.includes("/")) {
                return icon.startsWith("file:") ? icon : ("file://" + icon);
            }

            const p = Quickshell.iconPath(icon, "");
            if (p && p.length > 0)
                return p;
        }

        return Quickshell.iconPath("application-x-executable", "application-x-executable");
    }
}
