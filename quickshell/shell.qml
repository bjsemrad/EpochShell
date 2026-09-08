//@ pragma Env QT_FFMPEG_DECODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_FFMPEG_ENCODING_HW_DEVICE_TYPES=vaapi
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma UseQApplication
//@ pragma IconTheme kora

import Quickshell
import Quickshell.Wayland
import qs.modules

ShellRoot {
    Bar {}
    Notifications {}
    SoundOSD {}
    MediaOSD {}
    BrightnessOSD {}
    Polkit {}

    // One launcher for the session, not one per bar. Bar.qml builds its contents under
    // Variants { model: Quickshell.screens }, so the overlay used to be duplicated per screen.
    LauncherOverlay {}

    Ipc {}
}
