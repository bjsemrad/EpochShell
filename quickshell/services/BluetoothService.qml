pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: blue

    readonly property string headset: "headset"
    readonly property string mouse: "mouse"
    readonly property string keyboard: "keyboard"
    readonly property string smartphone: "smartphone"
    readonly property string speaker: "speaker"
    readonly property string display: "display"
    readonly property string watch: "watch"

    readonly property string currentBluetoothIcon: enabled ? connected ? "󰂱" : "󰂯" : "󰂲"

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: (adapter && adapter.enabled) ?? false
    readonly property bool discovering: (adapter && adapter.discovering) ?? false
    readonly property var devices: {
        if (!adapter || !adapter.devices) {
            return [];
        }
        let paired = adapter.devices.values.filter(dev => {
            return dev && !dev.paired;
        });
        return sortDevices(paired);
    }

    function scanForDevices() {
        adapter.discovering = true;
    }

    function stopScan() {
        adapter.discovering = false;
    }

    readonly property bool connected: {
        if (!adapter || !adapter.devices) {
            return false;
        }
        return adapter.devices.values.some(dev => dev.connected);
    }
    readonly property var pairedDevices: {
        if (!adapter || !adapter.devices) {
            return [];
        }
        let paired = adapter.devices.values.filter(dev => {
            return dev && (dev.paired || dev.trusted);
        });
        return sortDevices(paired);
    }

    function sortDevices(devices) {
        return devices.sort((a, b) => {
            const aName = a.name || a.deviceName || "";
            const bName = b.name || b.deviceName || "";
            const aAddr = a.address || "";
            const bAddr = b.address || "";

            const aHasRealName = aName.includes(" ") && aName.length > 3;
            const bHasRealName = bName.includes(" ") && bName.length > 3;

            if (aHasRealName && !bHasRealName)
                return -1;
            if (!aHasRealName && bHasRealName)
                return 1;

            if (aHasRealName && bHasRealName) {
                return aName.localeCompare(bName);
            }

            return aAddr.localeCompare(bAddr);
        });
    }

    Process {
        id: bluectl
    }

    function toggle(enabled) {
        bluectl.command = ["bluetoothctl", "power", enabled ? "on" : "off"];
        bluectl.running = true;
    }

    function getDeviceIcon(device) {
        let type = getDeviceType(device);
        if (type === headset) {
            return "󰋎";
        } else if (type === mouse) {
            return "󰍽";
        } else if (type === keyboard) {
            return "";
        } else if (type === smartphone) {
            return "";
        } else if (type === speaker) {
            return "󰓃";
        } else if (type === watch) {
            return "󰖉";
        } else if (type === display) {
            return "";
        } else {
            return "󰂯";
        }
    }

    function getDeviceType(device) {
        if (!device) {
            return "bluetooth";
        }

        const name = (device.name || device.deviceName || "").toLowerCase();
        const icon = (device.icon || "").toLowerCase();

        const audioKeywords = ["headset", "audio", "headphone", "airpod", "arctis"];
        if (audioKeywords.some(keyword => icon.includes(keyword) || name.includes(keyword))) {
            return headset;
        }

        if (icon.includes("mouse") || name.includes("mouse")) {
            return mouse;
        }

        if (icon.includes("keyboard") || name.includes("keyboard")) {
            return keyboard;
        }

        const phoneKeywords = ["phone", "iphone", "android", "samsung"];
        if (phoneKeywords.some(keyword => icon.includes(keyword) || name.includes(keyword))) {
            return smartphone;
        }

        if (icon.includes("watch") || name.includes("watch")) {
            return watch;
        }

        if (icon.includes("speaker") || name.includes("speaker")) {
            return speaker;
        }

        if (icon.includes("display") || name.includes("tv")) {
            return display;
        }

        return "bluetooth";
    }

    Process {
        id: blueman
        command: ["blueman-manager"]
    }
    function settings() {
        blueman.running = true;
    }
}
