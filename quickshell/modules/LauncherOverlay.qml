import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services as S
import qs.theme as T

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusiveZone: 0
    focusable: true
    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null

    property int currentIndex: -1
    property bool _visible: false
    property bool showingProviders: false
    readonly property bool backendDown: S.LauncherService.backendError.length > 0

    ListModel {
        id: providerModel
    }

    function appendProviderRow(name, prefix, text, subtext, icon) {
        providerModel.append({
            provider: "provider",
            name: name,
            identifier: prefix,
            text: text,
            subtext: subtext,
            icon: icon || "",
            action: "",
            preview: "",
            previewType: ""
        });
    }

    // Mirrors whatever EpochOxide reports: one row per live provider, labelled and prefixed the
    // way the backend describes itself, plus the synthetic "search everything" row.
    function buildProviderMenu() {
        providerModel.clear();
        for (const cap of S.LauncherService.providerCapabilities) {
            if (!cap.supportsQuery) continue;
            const prefix = cap.prefixes.length > 0 ? cap.prefixes[0] : "";
            root.appendProviderRow(cap.name, prefix, cap.namePretty, cap.description, cap.icon);
        }
        root.appendProviderRow(S.LauncherService.allPrefix, S.LauncherService.allPrefix, "All providers", "Search across every provider", "");
    }

    visible: _visible

    function open() {
        panelAnimate = false;
        inputField.text = "";
        showingProviders = false;
        currentIndex = -1;
        previewVisible = false;
        previewText = "";
        previewImage = "";
        previewProvider = "";
        previewSubtext = "";
        _visible = true;
        S.LauncherService.refreshProviders();
        S.LauncherService.setQuery("");
        inputField.forceActiveFocus();
        panelAnimateTimer.start();
    }

    Timer {
        id: panelAnimateTimer
        interval: 100
        repeat: false
        onTriggered: root.panelAnimate = true
    }

    function close() {
        _visible = false;
        inputField.text = "";
        showingProviders = false;
        currentIndex = -1;
        listView.currentIndex = -1;
    }

    function toggle() {
        if (_visible) {
            close();
        } else {
            open();
        }
    }

    IpcHandler {
        target: "launcher"
        property bool isOpen: root._visible

        function toggle(): void { root.toggle(); }
        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function openProvider(name: string): void { root.openProvider(name); }
        function openKeybinds(): void { root.openProvider("keybinds"); }
    }

    function chooseProvider(prefix) {
        showingProviders = false;
        inputField.text = prefix;
        inputField.forceActiveFocus();
        S.LauncherService.setQuery(inputField.text);
    }

    // Jumps straight to a provider by name, which is how a menu is opened now that each one is a
    // provider of its own: type its prefix for it. The name is held until the backend has answered
    // with its capabilities if the launcher is opened before that lands.
    property string pendingProvider: ""

    function openProvider(name) {
        root.open();
        root.pendingProvider = name;
        root.applyPendingProvider();
    }

    function applyPendingProvider() {
        if (root.pendingProvider.length === 0) return;
        const prefix = S.LauncherService.prefixForProvider(root.pendingProvider);
        if (prefix.length === 0) return;
        root.pendingProvider = "";
        root.chooseProvider(prefix);
    }

    // A row's data lives in the model; listView.itemAtIndex() only answers once a delegate for
    // that index has been created, which it has not on the first population of a freshly shown
    // window. Reading the view instead of the model is why the first search came up with no
    // preview until the selection moved and forced a second look.
    function rowAt(index) {
        const model = root.showingProviders ? providerModel : S.LauncherService.results;
        if (index < 0 || index >= model.count) return null;
        return model.get(index);
    }

    function activateCurrent() {
        if (currentIndex < 0) return;
        const row = root.rowAt(currentIndex);
        if (!row) return;
        if (root.showingProviders) {
            root.chooseProvider(row.identifier);
            return;
        }
        S.LauncherService.activate(row.provider, row.identifier, row.action);
        close();
    }

    function defaultScope() {
        return S.LauncherService.providerAvailable("apps") ? "apps" : "";
    }

    function scopedProvider() {
        const prefix = S.LauncherService.prefixFor(inputField.text);
        if (prefix.length > 0) return prefix === S.LauncherService.allPrefix ? "" : S.LauncherService.providerForPrefix(prefix);
        if (S.LauncherService.providerAvailable("calc") && S.LauncherService.isMathQuery(inputField.text)) return "calc";
        return root.defaultScope();
    }

    function scopeLabel() {
        if (root.showingProviders) return "Choose provider";
        if (S.LauncherService.prefixFor(inputField.text) === S.LauncherService.allPrefix) return "All providers";
        const provider = root.scopedProvider();
        return provider.length > 0 ? S.LauncherService.prettyName(provider) : "All providers";
    }

    function activeProvider() {
        if (root.showingProviders) return "";
        const provider = root.scopedProvider();
        return provider.indexOf(",") === -1 ? provider : "";
    }

    function chipActive(name, prefix) {
        if (root.showingProviders) return false;
        const typed = S.LauncherService.prefixFor(inputField.text);
        if (typed.length > 0) return typed === prefix;
        return name === root.scopedProvider();
    }

    function providerLabel(name, identifier) {
        if (name === "provider") return identifier || "→";
        return name;
    }

    property bool previewVisible: false
    property string previewProvider: ""
    property string previewTitle: ""
    property string previewText: ""
    property url previewImage: ""
    property string previewSubtext: ""
    property int previewReqCounter: 0
    property bool panelAnimate: true

    readonly property int previewTextMax: 4000
    // Formats Qt's own imageformats plugins can decode directly on this system.
    readonly property var nativeImageExtensions: ["png", "jpg", "jpeg", "gif", "bmp", "ico", "svg"]
    // Formats with no (or unreliable) native Qt decoder here; rendered to a cached PNG via an
    // external tool instead (see requestThumbnail). Needs poppler-utils/imagemagick on PATH.
    readonly property var convertibleImageExtensions: ["pdf", "heic", "heif", "webp", "tiff", "tif", "avif", "tga", "icns"]
    readonly property string previewCacheDir: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/epochshell/previews"

    function truncate(text, max) {
        if (typeof text !== "string") return "";
        return text.length > max ? text.slice(0, max) + "…" : text;
    }

    function fileUrl(path) {
        return Qt.resolvedUrl(path);
    }

    function fileExtension(path) {
        const idx = path.lastIndexOf(".");
        return idx < 0 ? "" : path.slice(idx + 1).toLowerCase();
    }

    function isNativeImagePath(path) {
        return nativeImageExtensions.indexOf(fileExtension(path)) !== -1;
    }

    function isConvertibleImagePath(path) {
        return convertibleImageExtensions.indexOf(fileExtension(path)) !== -1;
    }

    // Stable per-path cache key (FNV-1a), mirroring EpochOxide's own icon thumbnail stamping.
    function pathStamp(path) {
        let h = 0x811c9dc5;
        for (let i = 0; i < path.length; i++) {
            h ^= path.charCodeAt(i) & 0xff;
            h = Math.imul(h, 0x01000193);
        }
        return (h >>> 0).toString(16).padStart(8, "0");
    }

    function requestThumbnail(path) {
        const cache = root.previewCacheDir + "/" + root.pathStamp(path) + ".png";
        const ext = root.fileExtension(path);
        const convert = ext === "pdf"
            ? "pdftoppm -f 1 -l 1 -png -singlefile -scale-to 512 \"$1\" \"${2%.png}\""
            : "convert \"$1[0]\" -thumbnail 512x512 -background none \"$2\"";
        previewThumbProc.running = false;
        previewThumbProc.previewReq = root.previewReqCounter = root.previewReqCounter + 1;
        previewThumbProc.targetCache = cache;
        previewThumbProc.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname \"$2\")\" && { [ -f \"$2\" ] || " + convert + "; }",
            "sh", path, cache
        ];
        previewThumbProc.running = true;
    }

    function refreshPreview() {
        previewTimer.stop();
        if (!_visible) {
            previewVisible = false;
            return;
        }
        const row = root.rowAt(currentIndex);
        if (!row) {
            previewVisible = false;
            previewText = "";
            previewImage = "";
            return;
        }
        const provider = row.provider;
        const preview = row.preview;
        if ((provider === "files" || provider === "clipboard") && preview.length > 0) {
            previewVisible = true;
            previewProvider = provider;
            previewTitle = provider === "clipboard" ? "CLIPBOARD" : "FILE";
            previewSubtext = row.text;
            if (provider === "clipboard" || row.previewType === "text") {
                previewText = root.truncate(preview, root.previewTextMax);
                previewImage = "";
            } else if (isNativeImagePath(preview)) {
                previewText = "";
                previewImage = root.fileUrl(preview);
            } else if (isConvertibleImagePath(preview)) {
                previewText = "";
                previewImage = "";
                root.requestThumbnail(preview);
            } else {
                previewText = "";
                previewImage = "";
                previewFileProc.running = false;
                previewFileProc.previewReq = root.previewReqCounter = root.previewReqCounter + 1;
                previewFileProc.command = [
                    "sh", "-c",
                    "if [ -d \"$1\" ]; then ls -A \"$1\" | head -c 16000; else head -c 16000 \"$1\" 2>/dev/null; fi",
                    "sh", preview
                ];
                previewFileProc.running = true;
            }
            return;
        }
        previewVisible = false;
        previewText = "";
        previewImage = "";
    }

    Timer {
        id: previewTimer
        interval: 120
        repeat: false
        onTriggered: root.refreshPreview()
    }

    Process {
        id: previewFileProc
        property int previewReq: -1
        stdout: StdioCollector {
            id: previewFileOut
            waitForEnd: true
            onStreamFinished: {
                if (previewFileProc.previewReq !== root.previewReqCounter) return;
                const out = text || "";
                root.previewText = out.trim().length > 0 ? root.truncate(out, 16000) : "";
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (previewFileProc.previewReq !== root.previewReqCounter) return;
                if ((text || "").trim().length > 0 && root._visible && root.previewProvider === "files") {
                    root.previewText = "";
                }
            }
        }
    }

    Process {
        id: previewThumbProc
        property int previewReq: -1
        property string targetCache: ""
        onExited: function (exitCode, exitStatus) {
            if (previewThumbProc.previewReq !== root.previewReqCounter) return;
            if (exitCode === 0) root.previewImage = root.fileUrl(previewThumbProc.targetCache);
        }
    }

    onCurrentIndexChanged: previewTimer.restart()

    Keys.onEscapePressed: event => {
        close();
        event.accepted = true;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: panel
        readonly property string modeProvider: root.activeProvider()

        width: modeProvider === "files" || modeProvider === "clipboard"
            ? Math.round(root.width * 0.60)
            : root.previewVisible ? 1700 : 620
        Behavior on width { enabled: root.panelAnimate; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        height: modeProvider === "files" || modeProvider === "clipboard"
            ? Math.round(root.height * 0.60)
            : (root.previewProvider === "files" || root.previewProvider === "clipboard") && root.previewText.length > 0 ? 900 : 520
        Behavior on height { enabled: root.panelAnimate; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        radius: T.Config.popupRadius
        color: T.Config.background
        border.width: 1
        border.color: T.Config.outline
        anchors.centerIn: parent

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: T.Config.popupPadding * 2
                    }
                    spacing: T.Config.popupLayoutSpacing

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: inputRow.implicitHeight + T.Config.barModuleVerticalPadding * 2
                radius: T.Config.cardRadius
                color: T.Config.surfaceContainer
                border.width: 1
                border.color: inputField.activeFocus ? T.Config.accent : T.Config.outline

                RowLayout {
                    id: inputRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: T.Config.popupPadding
                        rightMargin: T.Config.popupPadding
                    }
                    spacing: T.Config.popupLayoutSpacing

                    Text {
                        text: "󰀻"
                        color: inputField.activeFocus ? T.Config.accent : T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.barIconSize
                    }

                    TextInput {
                        id: inputField
                        Layout.fillWidth: true
                        color: T.Config.surfaceText
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeLarge
                        clip: true
                        selectedTextColor: T.Config.background
                        selectionColor: T.Config.accent
                        selectByMouse: true
                        activeFocusOnTab: false

                        Keys.onDownPressed: event => {
                            root.moveSelection(1);
                            event.accepted = true;
                        }
                        Keys.onUpPressed: event => {
                            root.moveSelection(-1);
                            event.accepted = true;
                        }
                        Keys.onReturnPressed: event => {
                            root.activateCurrent();
                            event.accepted = true;
                        }
                        Keys.onEscapePressed: event => {
                            root.close();
                            event.accepted = true;
                        }

                        onTextChanged: {
                            showingProviders = text === ";";
                            S.LauncherService.setQuery(text);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: S.LauncherService.searching
                implicitHeight: 16
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 6
                    Layout.alignment: Qt.AlignLeft

                    Item {
                        implicitWidth: 12
                        implicitHeight: 12
                        RotationAnimation on rotation {
                            running: S.LauncherService.searching
                            from: 0
                            to: 360
                            duration: 800
                            loops: Animation.Infinite
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 5
                            border.width: 2
                            border.color: T.Config.accent
                            Rectangle {
                                width: 3
                                height: 3
                                radius: 1.5
                                color: T.Config.accent
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                            }
                        }
                    }

                    Text {
                        text: "Searching..."
                        color: T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeSubtext
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: T.Config.surfaceVariant
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    clip: true
                    model: root.showingProviders ? providerModel : S.LauncherService.results
                    spacing: 4
                    focus: false
                    boundsBehavior: Flickable.StopAtBounds
                    keyNavigationWraps: true
                    delegate: Rectangle {
                        id: delegateRoot
                        required property int index
                        required property string provider
                        required property string identifier
                        required property string text
                        required property string subtext
                        required property string icon
                        required property string action
                        required property string preview
                        required property string previewType

                        readonly property bool isCurrent: root.currentIndex === index
                        // An icon is either a freedesktop icon name for the image provider to
                        // resolve, or a glyph to draw in the theme font (a Nerd Font codepoint
                        // sits above the BMP's ASCII/symbol range, as one char or a surrogate
                        // pair). Menus name their icon by hand, so both are worth accepting.
                        readonly property bool iconIsGlyph: icon.length > 0 && icon.length <= 2 && icon.charCodeAt(0) > 0x2000
                        width: listView.width - 2
                        implicitHeight: 48
                        radius: T.Config.cardRadius
                        color: isCurrent ? T.Config.accentLightShade
                               : mouseArea.containsMouse ? T.Config.surfaceContainerHigh
                               : "transparent"
                        border.width: isCurrent ? 1 : 0
                        border.color: isCurrent ? T.Config.accent : "transparent"

                        RowLayout {
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: T.Config.popupPadding
                                rightMargin: T.Config.popupPadding
                            }
                            spacing: T.Config.popupLayoutSpacing

                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: T.Config.cardRadius
                                color: delegateRoot.isCurrent ? T.Config.surfaceContainerHigh : T.Config.surface
                                clip: true

                                Image {
                                    id: iconImage
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: delegateRoot.icon.length > 0 && !delegateRoot.iconIsGlyph ? "image://icon/" + delegateRoot.icon : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: delegateRoot.icon.length > 0 && !delegateRoot.iconIsGlyph && status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !iconImage.visible
                                    text: delegateRoot.iconIsGlyph
                                        ? delegateRoot.icon
                                        : delegateRoot.provider === "provider"
                                        ? (delegateRoot.identifier.length > 0 ? delegateRoot.identifier.charAt(0) : delegateRoot.text.charAt(0).toUpperCase())
                                        : (delegateRoot.text.length > 0 ? delegateRoot.text.charAt(0).toUpperCase() : "?")
                                    color: delegateRoot.iconIsGlyph ? T.Config.surfaceText : T.Config.inactive
                                    font.family: T.Config.fontFamily
                                    font.pixelSize: delegateRoot.iconIsGlyph ? T.Config.barIconSize : T.Config.fontSizeNormal
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: delegateRoot.provider === "clipboard" ? root.truncate(delegateRoot.text.replace(/\s+/g, " "), 30) : delegateRoot.text
                                    color: delegateRoot.isCurrent ? T.Config.accent : T.Config.surfaceText
                                    font.family: T.Config.fontFamily
                                    font.pixelSize: T.Config.fontSizeMedium
                                    font.bold: delegateRoot.isCurrent
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    text: delegateRoot.provider === "clipboard" ? delegateRoot.subtext.replace(/\s+/g, " ") : delegateRoot.subtext
                                    color: T.Config.inactive
                                    font.family: T.Config.fontFamily
                                    font.pixelSize: T.Config.fontSizeNormal
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            Rectangle {
                                visible: delegateRoot.provider === "provider"
                                Layout.preferredWidth: kbdText.implicitWidth + 14
                                Layout.preferredHeight: 18
                                radius: 4
                                color: T.Config.surface
                                border.width: 1
                                border.color: T.Config.surfaceVariant

                                Text {
                                    id: kbdText
                                    anchors.centerIn: parent
                                    text: delegateRoot.identifier.length > 0 ? delegateRoot.identifier : "type"
                                    color: T.Config.inactive
                                    font.family: T.Config.fontFamily
                                    font.pixelSize: T.Config.fontSizeSubtext
                                }
                            }

                            Text {
                                visible: delegateRoot.provider !== "provider"
                                text: root.providerLabel(delegateRoot.provider, delegateRoot.identifier)
                                color: T.Config.inactive
                                font.family: T.Config.fontFamily
                                font.pixelSize: T.Config.fontSizeSubtext
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.currentIndex = delegateRoot.index;
                                listView.currentIndex = delegateRoot.index;
                                listView.positionViewAtIndex(delegateRoot.index, ListView.Center);
                            }
                            onDoubleClicked: {
                                root.currentIndex = delegateRoot.index;
                                root.activateCurrent();
                            }
                        }
                    }

                    onCountChanged: {
                        if (listView.count === 0) {
                            root.previewVisible = false;
                            root.currentIndex = -1;
                        } else if (root.currentIndex < 0 || root.currentIndex >= listView.count) {
                            root.currentIndex = 0;
                            listView.currentIndex = 0;
                        } else {
                            previewTimer.restart();
                        }
                    }
                }

                Text {
                    anchors.centerIn: listView
                    visible: listView.count === 0 && !S.LauncherService.searching && !root.backendDown
                    text: "No results"
                    color: T.Config.inactive
                    font.family: T.Config.fontFamily
                    font.pixelSize: T.Config.fontSizeNormal
                }

                ColumnLayout {
                    anchors.centerIn: listView
                    width: listView.width - T.Config.popupPadding * 2
                    visible: root.backendDown
                    spacing: 6

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰅚"
                        color: T.Config.red
                        font.family: T.Config.fontFamily
                        font.pixelSize: 48
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: S.LauncherService.backendError
                        color: T.Config.red
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeLarge
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: S.LauncherService.socketPath
                        color: T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeNormal
                        elide: Text.ElideMiddle
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Retrying… · systemctl --user restart epochoxide"
                        color: T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeSubtext
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: root.backendDown ? S.LauncherService.backendError : root.scopeLabel() + " · " + listView.count + " results"
                    color: root.backendDown ? T.Config.red
                           : S.LauncherService.searching ? T.Config.accent : T.Config.inactive
                    font.family: T.Config.fontFamily
                    font.pixelSize: T.Config.fontSizeSubtext
                }

                Item {
                    Layout.fillWidth: true
                }

                Repeater {
                    model: providerModel

                    delegate: Text {
                        required property string identifier
                        required property string name

                        text: identifier.length > 0 ? identifier : name
                        color: root.chipActive(name, identifier) ? T.Config.accent : T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeSubtext
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.chooseProvider(identifier)
                        }
                    }
                }
            }
            }

        }

        Rectangle {
            Layout.preferredWidth: root.previewVisible ? Math.round(panel.width * 0.62) : 0
            Layout.fillHeight: true
            visible: root.previewVisible
            Behavior on Layout.preferredWidth { enabled: root.panelAnimate; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            clip: true
            color: "transparent"

                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    width: 1
                    color: T.Config.surfaceVariant
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: T.Config.popupPadding * 2
                    }
                    spacing: T.Config.popupLayoutSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: root.previewTitle
                            color: T.Config.accent
                            font.family: T.Config.fontFamily
                            font.pixelSize: T.Config.fontSizeXLarge
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.providerLabel(root.previewProvider)
                            color: T.Config.inactive
                            font.family: T.Config.fontFamily
                            font.pixelSize: T.Config.fontSizeMedium
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.previewSubtext.length > 0
                        text: root.previewSubtext
                        color: T.Config.inactive
                        font.family: T.Config.fontFamily
                        font.pixelSize: T.Config.fontSizeMedium
                        elide: Text.ElideMiddle
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: T.Config.surfaceVariant
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            visible: root.previewImage.toString() !== ""
                            source: root.previewImage
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            sourceSize.width: 1024
                            sourceSize.height: 820
                        }

                        Flickable {
                            anchors.fill: parent
                            visible: root.previewImage.toString() === "" && root.previewText.length > 0
                            contentWidth: width
                            contentHeight: previewBody.implicitHeight

                            Text {
                                id: previewBody
                                width: parent.width
                                text: root.previewText
                                color: T.Config.surfaceText
                                font.family: T.Config.fontFamily
                                font.pixelSize: T.Config.fontSizeLarge
                                wrapMode: Text.WrapAnywhere
                                textFormat: Text.PlainText
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: root.previewImage.toString() === "" && root.previewText.length === 0
                            spacing: 6

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰈔"
                                color: T.Config.inactive
                                font.family: T.Config.fontFamily
                                font.pixelSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No preview"
                                color: T.Config.inactive
                                font.family: T.Config.fontFamily
                                font.pixelSize: T.Config.fontSizeLarge
                            }
                        }
                    }
                }
            }
        }
    }

    function moveSelection(delta) {
        const count = listView.count;
        if (count === 0) {
            currentIndex = -1;
            return;
        }
        currentIndex = (currentIndex + delta + count) % count;
        listView.currentIndex = currentIndex;
        listView.positionViewAtIndex(currentIndex, ListView.Center);
    }

    Connections {
        target: S.LauncherService
        function onProvidersUpdated() {
            root.buildProviderMenu();
            root.applyPendingProvider();
        }
    }

    Component.onCompleted: {
        root.buildProviderMenu()
    }
}
