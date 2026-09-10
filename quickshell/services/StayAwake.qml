pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Stay awake, over EpochOxide's API.
//
// The lock itself lives in the backend, which holds a `systemd-inhibit` process: that is what lets
// `epochctl toggle stay-awake` work with the shell closed, and what keeps the state across a shell
// reload. This service asks what that state is and offers to flip it.
//
// The shell adds one thing the backend cannot: a Wayland idle-inhibit against its own surface, so
// the compositor never reports idle in the first place. That belongs here because a Wayland
// inhibitor needs a surface, and the daemon has none. See Bar.qml for where it is attached.
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/epochoxide.sock"

    property bool enabled: false
    property string reason: ""
    property int seconds: 0
    property bool available: false
    property string unavailableReason: ""
    property string status: ""

    readonly property bool connected: socketLoader.item !== null && socketLoader.item.connected
    readonly property string icon: "󰒳"

    // "12 minutes", for the tooltip-ish line in a panel.
    readonly property string held: {
        const total = root.seconds;
        if (total < 60) return "moments";
        const minutes = Math.floor(total / 60);
        if (minutes < 60) return minutes === 1 ? "1 minute" : (minutes + " minutes");
        const hours = Math.floor(minutes / 60);
        return hours === 1 ? "1 hour" : (hours + " hours");
    }

    function refresh() {
        request("system.stayAwake", {});
    }

    // Omitting `enabled` asks the backend to flip whatever it currently is, which is what a
    // keybinding or a click means; the state is decided there so two callers cannot disagree.
    function toggle() {
        request("system.setStayAwake", {});
    }

    function set(value) {
        request("system.setStayAwake", { enabled: value === true });
    }

    function request(method, params) {
        const socket = socketLoader.item;
        if (!socket || !socket.connected) return;
        socket.write(JSON.stringify({ type: "api", method: method, params: params || {}, version: 1 }) + "\n");
        socket.flush();
    }

    function apply(ok, data, error) {
        if (!ok) {
            available = false;
            unavailableReason = error || "Stay awake is unavailable";
            return;
        }
        enabled = data.enabled === true;
        reason = String(data.reason || "");
        seconds = Number(data.seconds || 0);
        available = data.available === true;
        unavailableReason = String(data.unavailable_reason || "");
    }

    function rebuildSocket() {
        socketLoader.active = false;
        socketLoader.active = true;
    }

    // The clock is ticked locally and the backend asked rarely: the state only changes when
    // something asks it to, and this is drawn in the bar.
    Timer {
        interval: 1000
        repeat: true
        running: root.enabled
        onTriggered: root.seconds += 1
    }

    // triggeredOnStart matters more than the interval: a request sent from the connect handler is
    // dropped when the socket is not writable yet, and without this the state stays unknown -- and
    // anything bound to it invisible -- until the first tick half a minute later.
    Timer {
        interval: 30000
        repeat: true
        running: root.connected
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: retry
        interval: 5000
        repeat: true
        running: !root.connected
        onTriggered: root.rebuildSocket()
    }

    Loader {
        id: socketLoader
        active: true

        sourceComponent: Socket {
            id: epochoxideSocket
            path: root.socketPath
            connected: true

            onConnectionStateChanged: {
                if (epochoxideSocket.connected) root.refresh();
            }

            parser: SplitParser {
                onRead: function (line) {
                    let response;
                    try {
                        response = JSON.parse(line);
                    } catch (e) {
                        console.log("stay-awake epochoxide parse error:", e, line);
                        return;
                    }
                    const data = response.data || {};
                    root.apply(response.ok !== false, data, response.error || data.message || "");
                }
            }
        }
    }
}
