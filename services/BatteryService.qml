pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: batteryService

    property real percentage: 0
    property bool charging: false

    property bool hasBattery: {
        for (let dev of UPower.devices.values) {
            if (dev.isPresent && dev.isLaptopBattery) {
                return true;
            }
        }
        return false;
    }

    function batteryIcon() {
        let pct = Math.round(batteryService.percentage);
        if (pct > 95)
            return batteryService.charging ? "󰂋" : "󰁹";
        if (pct > 55)
            return batteryService.charging ? "󰢞" : "󰂀";
        if (pct > 45)
            return batteryService.charging ? "󰂈" : "󰁽";
        if (pct > 20)
            return batteryService.charging ? "󰂆" : "󰁻";
        return batteryService.charging ? "󰢜" : "󰁺";
    }

    function stateText() {
        if (batteryService.charging) {
            return "Full Charge: " + timeToString(UPower.displayDevice.timeToFull);
        } else {
            return "Remaining: " + timeToString(UPower.displayDevice.timeToEmpty);
        }
    }

    function timeToString(input) {
        let time = secondsToHMS(input);
        let textStr = time.hours > 0 ? time.hours + " h, " : "";
        textStr += time.minutes > 0 ? time.minutes + " m" : "";
        return textStr;
    }

    function secondsToHMS(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = seconds % 60;
        return {
            hours: h,
            minutes: m,
            seconds: s
        };
    }

    function computePercentage(pct) {
        return pct * 100;
    }

    Component.onCompleted: {
        if (UPower.displayDevice) {
            percentage = computePercentage(UPower.displayDevice.percentage);
            charging = (UPower.displayDevice.state === UPowerDeviceState.Charging);
        }
    }

    Connections {
        target: UPower.displayDevice

        function onPercentageChanged() {
            let pct = UPower.displayDevice ? UPower.displayDevice.percentage : 0;
            batteryService.percentage = computePercentage(pct);
        }

        function onStateChanged() {
            batteryService.charging = (UPower.displayDevice.state === UPowerDeviceState.Charging);
        }
    }
}
