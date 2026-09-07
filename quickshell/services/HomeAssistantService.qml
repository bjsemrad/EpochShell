pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: hass

    readonly property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/epochshell/hass.json"

    property bool configured: false
    property bool connected: false
    property bool loading: false
    property string baseUrl: ""
    property string token: ""
    property string statusText: "Not configured"
    property var favorites: []
    property var states: ({})
    property ListModel rows: ListModel {}

    function normalizeBaseUrl(value) {
        let url = String(value || "").trim();
        while (url.endsWith("/")) url = url.slice(0, -1);
        return url;
    }

    function applyConfig(text) {
        try {
            const cfg = text && text.trim().length > 0 ? JSON.parse(text) : {};
            baseUrl = normalizeBaseUrl(cfg.baseUrl || cfg.url || "");
            token = String(cfg.token || "");
            favorites = Array.isArray(cfg.favorites) ? cfg.favorites : [];
            configured = baseUrl.length > 0 && token.length > 0;
            statusText = configured ? "Ready" : "Configure ~/.config/epochshell/hass.json";
            if (configured) refresh();
        } catch (e) {
            configured = false;
            connected = false;
            statusText = "Invalid hass.json";
            console.log("hass config parse error:", e);
        }
    }

    function iconForDomain(domain, state) {
        switch (domain) {
        case "light": return state === "on" ? "󰌵" : "󰌶";
        case "switch": return state === "on" ? "󰨚" : "󰨙";
        case "fan": return "󰈐";
        case "input_boolean": return state === "on" ? "󰨚" : "󰨙";
        case "scene": return "󰝥";
        case "script": return "󰯂";
        case "lock": return state === "locked" ? "󰌾" : "󰌿";
        case "cover": return "󰖲";
        case "climate": return "󰔏";
        case "sensor": return "󰔏";
        case "binary_sensor": return state === "on" ? "󰔡" : "󰔢";
        default: return "󰟐";
        }
    }

    function stateLabel(entity) {
        const attrs = entity.attributes || {};
        const unit = attrs.unit_of_measurement || "";
        const state = String(entity.state || "unknown");
        return unit.length > 0 ? state + " " + unit : state;
    }

    function rebuildRows() {
        rows.clear();
        for (let i = 0; i < favorites.length; i++) {
            const id = String(favorites[i]);
            const entity = states[id];
            if (!entity) {
                rows.append({
                    entityId: id,
                    domain: id.split(".")[0] || "",
                    name: id,
                    state: "missing",
                    icon: "󰅙",
                    controllable: false
                });
                continue;
            }

            const domain = id.split(".")[0] || "";
            const attrs = entity.attributes || {};
            rows.append({
                entityId: id,
                domain: domain,
                name: attrs.friendly_name || id,
                state: stateLabel(entity),
                icon: iconForDomain(domain, entity.state),
                controllable: ["light", "switch", "fan", "input_boolean", "humidifier", "scene", "script", "lock"].indexOf(domain) !== -1
            });
        }
    }

    function refresh() {
        if (!configured || loading) return;
        loading = true;
        statusText = "Refreshing...";
        refreshProc.command = ["curl", "-fsS", "-H", "Authorization: Bearer " + token, "-H", "Content-Type: application/json", baseUrl + "/api/states"];
        refreshProc.running = true;
    }

    function serviceForEntity(entityId) {
        const domain = String(entityId || "").split(".")[0] || "";
        const entity = states[entityId] || {};
        if (domain === "scene" || domain === "script") return "turn_on";
        if (domain === "lock") return entity.state === "locked" ? "unlock" : "lock";
        return "toggle";
    }

    function toggleEntity(entityId) {
        if (!configured || loading) return;
        const domain = String(entityId || "").split(".")[0] || "";
        if (domain.length === 0) return;
        const service = serviceForEntity(entityId);
        loading = true;
        statusText = "Sending " + entityId + "...";
        callProc.command = ["curl", "-fsS", "-X", "POST", "-H", "Authorization: Bearer " + token, "-H", "Content-Type: application/json", "-d", JSON.stringify({ entity_id: entityId }), baseUrl + "/api/services/" + domain + "/" + service];
        callProc.running = true;
    }

    FileView {
        path: hass.configPath
        watchChanges: true
        printErrors: false
        onLoaded: hass.applyConfig(text())
        onLoadFailed: hass.applyConfig("")
        onFileChanged: reload()
    }

    Process {
        id: refreshProc
        stdout: StdioCollector {
            id: refreshOut
            waitForEnd: true
            onStreamFinished: {
                try {
                    const text = String(refreshOut.text || "").trim();
                    if (text.length === 0) throw new Error("empty response");
                    const arr = JSON.parse(text);
                    const map = {};
                    for (let i = 0; i < arr.length; i++) map[arr[i].entity_id] = arr[i];
                    states = map;
                    connected = true;
                    statusText = favorites.length > 0 ? "Connected" : "No favorites configured";
                    rebuildRows();
                } catch (e) {
                    connected = false;
                    statusText = "Failed to parse Home Assistant response";
                    console.log("hass state parse error:", e);
                }
                loading = false;
            }
        }
        stderr: StdioCollector { waitForEnd: true }
    }

    Process {
        id: callProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                loading = false;
                refresh();
            }
        }
        stderr: StdioCollector { waitForEnd: true }
        onExited: loading = false
    }

    Timer {
        interval: 30000
        running: configured
        repeat: true
        onTriggered: refresh()
    }
}
