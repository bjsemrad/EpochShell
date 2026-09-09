pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property alias toastModel: toastModel
    property alias historyModel: historyModel
    property var liveNotifications: ({})
    property bool doNotDisturb: false
    property int unreadCount: 0
    readonly property int historyLimit: 30
    readonly property int normalTimeout: 3500
    readonly property int lowTimeout: 2000
    readonly property string imageStateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/epochshell/notifications/images/"

    readonly property var browserNames: ({
        "brave": "brave-",
        "Brave": "brave-",
        "chrome": "chrome-",
        "Chrome": "chrome-",
        "Chromium": "chrome-",
        "firefox": "firefox-",
        "Firefox": "firefox-",
        "vivaldi": "vivaldi-",
        "Vivaldi": "vivaldi-",
        "edge": "edge-",
        "Edge": "edge-",
        "chromium": "chrome-",
    })

    readonly property var browserGenericClasses: ({
        "brave-": ["brave-browser"],
        "chrome-": ["chrome", "chromium", "google-chrome", "google-chrome-stable"],
        "firefox-": ["firefox"],
        "vivaldi-": ["vivaldi", "vivaldi-stable"],
        "edge-": ["microsoft-edge", "microsoft-edge-stable"]
    })

    function isGenericBrowserClass(prefix, cls) {
        const generic = browserGenericClasses[prefix] || [];
        const lower = String(cls || "").toLowerCase();
        for (let i = 0; i < generic.length; i++) {
            if (lower === generic[i]) return true;
        }
        return false;
    }

    function browserPrefixForAppName(appName) {
        const exact = browserNames[appName];
        if (exact) return exact;

        const lower = String(appName || "").toLowerCase();
        if (lower.indexOf("brave") !== -1) return "brave-";
        if (lower.indexOf("chrome") !== -1 || lower.indexOf("chromium") !== -1) return "chrome-";
        if (lower.indexOf("firefox") !== -1) return "firefox-";
        if (lower.indexOf("vivaldi") !== -1) return "vivaldi-";
        if (lower.indexOf("edge") !== -1) return "edge-";
        return "";
    }

    function normalizeClass(cls) {
        return String(cls || "").replace(/__-?Default$/, "");
    }

    function chromiumOriginHost(body) {
        const text = String(body || "").toLowerCase();
        let match = /^\s*<a\b[^>]*>\s*(?:https?:\/\/|www\.)?((?:[a-z0-9-]+\.)+[a-z]{2,})/i.exec(text);
        if (match) return match[1];
        match = /^\s*(?:https?:\/\/|www\.)?((?:[a-z0-9-]+\.)+[a-z]{2,})(?::\d+)?(?:\/\S*)?\s+/i.exec(text);
        return match ? match[1] : "";
    }

    function originSignals(host) {
        const value = String(host || "").toLowerCase();
        if (value.length === 0) return [];
        const out = [value];
        if (value.startsWith("www.")) out.push(value.slice(4));
        if (value.indexOf("mail.google.") !== -1) out.push("gmail");
        const parts = value.split(/[\-.]+/).filter(p => p.length >= 4 && ["mail", "google"].indexOf(p) === -1);
        for (let i = 0; i < parts.length; i++) out.push(parts[i]);
        return out;
    }

    function findBestBrowserWindow(appName, desktopEntry, title, body) {
        const browserPrefix = browserPrefixForAppName(`${appName} ${desktopEntry}`);
        if (!browserPrefix) return null;

        const prefix = browserPrefix.toLowerCase();
        const toplevels = [];

        // One loop over normalized windows: the compositor-specific branches this used to have
        // are gone now that CompositorService reports the same shape for every backend.
        const windows = CompositorService.windows;
        for (let i = 0; i < windows.length; i++) {
            const cls = normalizeClass(windows[i].app_id || "");
            if (!cls.toLowerCase().startsWith(prefix)) continue;
            toplevels.push({
                cls: cls,
                title: String(windows[i].title || "").toLowerCase(),
                generic: isGenericBrowserClass(prefix, cls),
                win: windows[i]
            });
        }

        if (toplevels.length === 0) return null;
        if (toplevels.length === 1) return toplevels[0];

        const tl = String(title || "").toLowerCase();
        const tokens = String(appName || "")
            .toLowerCase()
            .replace(/[^a-z0-9 ]+/g, " ")
            .split(/\s+/)
            .filter(t => t.length >= 3);
        const summaryTokens = tl
            .replace(/[^a-z0-9 ]+/g, " ")
            .split(/\s+/)
            .filter(t => t.length >= 4 && ["from", "the", "for", "with", "this", "that", "your", "have"].indexOf(t) === -1);
        const signals = originSignals(chromiumOriginHost(body));

        let best = toplevels[0];
        let bestScore = -Infinity;
        for (let i = 0; i < toplevels.length; i++) {
            const t = toplevels[i];
            let score = t.generic ? -100 : 0;
            for (let n = 0; n < signals.length; n++) {
                if (t.cls.toLowerCase().indexOf(signals[n]) !== -1) score += n === 0 ? 120 : 80;
            }
            for (let n = 0; n < tokens.length; n++) {
                if (t.cls.toLowerCase().indexOf(tokens[n]) !== -1) score += 30;
            }
            for (let n = 0; n < summaryTokens.length; n++) {
                if (t.cls.toLowerCase().indexOf(summaryTokens[n]) !== -1) score += 15;
            }
            if (tl.length >= 3) {
                if (tl.indexOf(t.title) !== -1 && t.title.length >= 5) score += 15;
                if (t.title.indexOf(tl) !== -1) score += 20;
            }
            if (score > bestScore) {
                bestScore = score;
                best = t;
            }
        }

        if (bestScore > -50) return best;

        if (CompositorService.activeWindowClass.toLowerCase().startsWith(prefix)
                && !isGenericBrowserClass(prefix, CompositorService.activeWindowClass)) {
            return { cls: normalizeClass(CompositorService.activeWindowClass), win: null };
        }

        for (let i = 0; i < toplevels.length; i++) {
            if (!toplevels[i].generic) {
                return toplevels[i];
            }
        }

        if (CompositorService.activeWindowClass.toLowerCase().startsWith(prefix)) {
            return { cls: normalizeClass(CompositorService.activeWindowClass), win: null };
        }

        return toplevels[0];
    }

    function workspaceIconForWindow(win) {
        if (!win || !win.app_id) return "";
        const entry = CompositorService.getDesktopEntry(String(win.app_id));
        return entry ? CompositorService.getDesktopIcon(entry) : "";
    }

    function localImageFile(value) {
        let path = String(value || "");
        if (path.startsWith("file://")) {
            path = path.slice(7);
            try {
                path = decodeURIComponent(path);
            } catch (e) {
            }
        } else if (path.startsWith("image://icon/")) {
            path = path.slice("image://icon/".length);
        }
        return path.startsWith("/") ? path : "";
    }

    function persistNotificationImages(notificationId, timestamp, appIcon, image) {
        const stem = String(timestamp) + "-" + String(notificationId);
        const out = { appIcon: String(appIcon || ""), image: String(image || "") };
        const command = ["bash", "-c",
            "dir=$1; shift\n" +
            "mkdir -p \"$dir\" || exit 0\n" +
            "while [ $# -ge 2 ]; do\n" +
            "  if [ -f \"$1\" ] && timeout 5 head -c 5242881 -- \"$1\" > \"$2.tmp\" 2>/dev/null && [ $(stat -c%s -- \"$2.tmp\") -le 5242880 ]; then mv -f -- \"$2.tmp\" \"$2\"; else rm -f -- \"$2.tmp\"; fi\n" +
            "  shift 2\n" +
            "done", "--", imageStateDir];
        let copies = 0;

        const appIconSource = localImageFile(out.appIcon);
        if (appIconSource.length > 0) {
            const target = imageStateDir + stem + "-appIcon";
            command.push(appIconSource, target);
            out.appIcon = "file://" + target;
            copies += 1;
        } else if (out.appIcon.startsWith("image://")) {
            out.appIcon = "";
        }

        const imageSource = localImageFile(out.image);
        if (imageSource.length > 0) {
            const target = imageStateDir + stem + "-image";
            command.push(imageSource, target);
            out.image = "file://" + target;
            copies += 1;
        } else if (out.image.startsWith("image://")) {
            out.image = "";
        }

        if (copies > 0) Quickshell.execDetached(command);
        return out;
    }

    function snapshotOf(notification, persistImages, notificationId, timestamp) {
        const appName = String(notification.appName || "");
        const desktopEntry = String(notification.desktopEntry || "");
        const image = String(notification.image || "");
        const appIcon = String(notification.appIcon || "");
        const summary = String(notification.summary || "");
        const body = String(notification.body || "");
        const imageValues = persistImages ? persistNotificationImages(notificationId, timestamp, appIcon, image) : { appIcon: appIcon, image: image };
        let windowClass = "";
        let displayAppIcon = imageValues.appIcon;
        let displayImage = imageValues.image;

        const isBrowser = browserPrefixForAppName(`${appName} ${desktopEntry}`).length > 0;
        const hasImage = displayImage.length > 0;
        const hasAppIcon = displayAppIcon.length > 0;

        if (isBrowser) {
            const win = findBestBrowserWindow(appName, desktopEntry, summary, body);
            if (win) {
                windowClass = win.cls;
                if (!hasImage && !hasAppIcon) {
                    displayAppIcon = workspaceIconForWindow(win.win);
                }
            }
        } else {
            if (hasAppIcon) {
                displayAppIcon = imageValues.appIcon;
            } else if (desktopEntry.length > 0) {
                const entry = CompositorService.getDesktopEntry(desktopEntry);
                if (entry) {
                    displayAppIcon = CompositorService.getDesktopIcon(entry);
                }
            }
            if (displayAppIcon.length === 0 && appName.length > 0) {
                const entry = CompositorService.getDesktopEntry(appName);
                if (entry) {
                    displayAppIcon = CompositorService.getDesktopIcon(entry);
                }
            }
        }

        return {
            notificationId: notificationId,
            appName: appName,
            appIcon: displayAppIcon,
            windowClass: windowClass,
            desktopEntry: desktopEntry,
            summary: String(notification.summary || ""),
            body: isBrowser ? body
                .replace(/^\s*<a\b[^>]*>\s*(?:https?:\/\/|www\.)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?(?:\/[^<\s]*)?\s*<\/a>\s*/i, "")
                .replace(/^\s*(?:https?:\/\/|www\.)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?(?:\/\S*)?\s+/i, "") : body,
            image: displayImage,
            urgency: notification.urgency,
            timestamp: timestamp
        };
    }

    function handleNotification(notification) {
        notification.tracked = true;

        const timestamp = Date.now();
        const notificationId = notification.id || timestamp;
        const historyItem = snapshotOf(notification, true, notificationId, timestamp);
        const toastItem = snapshotOf(notification, false, notificationId, timestamp);
        liveNotifications[notificationId] = notification;

        notification.closed.connect(function() {
            if (liveNotifications[notificationId] === notification) {
                delete liveNotifications[notificationId];
            }
        });

        addHistory(historyItem);
        unreadCount += 1;

        if (!doNotDisturb) {
            toastModel.insert(0, toastItem);
        }
    }

    function addHistory(item) {
        historyModel.insert(0, item);
        while (historyModel.count > historyLimit) {
            historyModel.remove(historyModel.count - 1);
        }
    }

    function dismissToast(index) {
        if (index < 0 || index >= toastModel.count) return;

        const item = toastModel.get(index);
        closeLiveNotification(item.notificationId);
        toastModel.remove(index);
    }

    function expireToast(index) {
        if (index < 0 || index >= toastModel.count) return;

        const item = toastModel.get(index);
        if (item.urgency === NotificationUrgency.Critical) return;

        closeLiveNotification(item.notificationId);
        toastModel.remove(index);
    }

    function dismissAllToasts() {
        for (let i = toastModel.count - 1; i >= 0; i--) {
            dismissToast(i);
        }
    }

    function clearHistory() {
        historyModel.clear();
        unreadCount = 0;
    }

    function dismissHistory(index) {
        if (index < 0 || index >= historyModel.count) return;

        const item = historyModel.get(index);
        closeLiveNotification(item.notificationId);
        removeToastById(item.notificationId);
        historyModel.remove(index);
    }

    function markRead() {
        unreadCount = 0;
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb;
        if (doNotDisturb) dismissAllToasts();
    }

    function timeoutFor(urgency) {
        if (urgency === NotificationUrgency.Critical) return 0;
        if (urgency === NotificationUrgency.Low) return lowTimeout;
        return normalTimeout;
    }

    function closeLiveNotification(id) {
        const notification = liveNotifications[id];
        if (!notification) return;

        try {
            notification.dismiss();
        } catch (e) {
        }
        delete liveNotifications[id];
    }

    function invokeDefaultAction(id) {
        const notification = liveNotifications[id];
        if (!notification) return false;

        try {
            if (notification.actions) {
                for (let i = 0; i < notification.actions.length; i++) {
                    const action = notification.actions[i];
                    if (action && action.identifier === "default") {
                        action.invoke();
                        return true;
                    }
                }
            }
        } catch (e) {
        }
        return false;
    }

    function closeNotificationEverywhere(id) {
        closeLiveNotification(id);
        removeToastById(id);
        removeHistoryById(id);
    }

    function invokeDefault(id) {
        invokeDefaultAction(id);
        closeNotificationEverywhere(id);
    }

    function focusAndDismiss(id, appName, windowClass) {
        if (invokeDefaultAction(id)) {
            closeNotificationEverywhere(id);
            return;
        }
        if (windowClass && windowClass.length > 0) {
            CompositorService.focusWindowByClass(windowClass);
        } else if (appName && appName.length > 0) {
            CompositorService.focusWindowByAppName(appName);
        }
        closeNotificationEverywhere(id);
    }

    function focusFromHistory(id, appName, index, windowClass) {
        if (invokeDefaultAction(id)) {
            closeNotificationEverywhere(id);
            return;
        }
        if (windowClass && windowClass.length > 0) {
            CompositorService.focusWindowByClass(windowClass);
        } else if (appName && appName.length > 0) {
            CompositorService.focusWindowByAppName(appName);
        }
        if (index !== undefined && index !== null) {
            dismissHistory(index);
        }
    }

    function removeToastById(id) {
        for (let i = toastModel.count - 1; i >= 0; i--) {
            if (toastModel.get(i).notificationId === id) {
                toastModel.remove(i);
            }
        }
    }

    function removeHistoryById(id) {
        for (let i = historyModel.count - 1; i >= 0; i--) {
            if (historyModel.get(i).notificationId === id) {
                historyModel.remove(i);
            }
        }
    }

    ListModel {
        id: toastModel
    }

    ListModel {
        id: historyModel
    }

    NotificationServer {
        id: server
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: false
        persistenceSupported: false

        onNotification: notification => root.handleNotification(notification)
    }
}
