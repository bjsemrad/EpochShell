pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  /* Main palette */
  property color bg: "#000000"
  property color inactive:  "#758799"
  property color active:  fg
  property color activeSelection: "#2A2A2A"

   property color black:    "#0e1013"
    property color bgDark:   "#1E2127"
    property color bg0:      "#1f2329"
    property color bg1:      "#282c34"
    property color bg2:      "#30363f"
    property color bg3:      "#323641"

    //
    // ───────────────────────────────────────────────
    //  FG / NEUTRALS
    // ───────────────────────────────────────────────
    //
    property color fg:        "#a0a8b7"
    property color fgDark:    "#abb2bf"
    // property color grey:      "#7a818e"
    property color grey: "#535965"

    //
    // ───────────────────────────────────────────────
    //  ACCENT COLORS
    // ───────────────────────────────────────────────
    //
     property color purple: "#bf68d9"
    property color green: "#8ebd6b"
    property color orange: "#cc9057"
    property color blue: "#4fa6ed"
   property color  yellow: "#e2b86b"
    property color cyan: "#48b0bd"
    property color red: "#e55561"
    property color bg_blue: "#61afef"
    property color bg_yellow: "#e8c88c"
    // property color purple:    "#bf68d9"
    // property color green:     "#8ebd6b"
    // property color orange:    "#cc9057"
    // property color blue:      "#4fa6ed"
    // property color yellow:    "#e2b86b"
    // property color cyan:      "#48b0bd"
    // property color red:       "#e55561"

    //
    // ───────────────────────────────────────────────
    //  SPECIAL
    // ───────────────────────────────────────────────
    //
    property color osdBg:  bg

    //
    // ───────────────────────────────────────────────
    //  WORKSPACE COLORS (RECOMMENDED)
    // ───────────────────────────────────────────────
    //
    property color wsActiveFg:     blue        // "#4fa6ed"
    property color wsActiveBg:     bg1         // "#282c34"

    property color wsInactiveFg:   grey        // "#7a818e"
    property color wsInactiveBg:   bg0         // "#1f2329"

    /* Misc */
    property string fontFamily: "JetBrainsMono Nerd Font Propo"


    property int networkPopupWidth: 400
    property int tailscalePopupWidth: 550
    property int bluetoothPopupWidth: 400
    property int audioPopupWidth: 300
    property int systemPopupWidth: 200
    property int batteryPopupWidth: 250



    property int tailscalePeersFontSize: 13 

    property int selectedBorderWidth: 1

}
