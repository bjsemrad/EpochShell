pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: nixService

    property var lo: ["sh", "-c", "nixos-version --hash 2>/dev/null | cut -c 1-7 || echo 'N/A'"]
    property var remoteRevisionCommand: ["sh", "-c", "git ls-remote https://github.com/NixOS/nixpkgs.git nixos- 2>/dev/null | cut -c 1-7 || echo 'N/A'"]

    Process {
        id: activeConnCmd
        command: ["sh", "-c", "nixos-version --hash 2>/dev/null | cut -c 1-7 || echo 'NONE'"]

        stdout: StdioCollector {
            onStreamFinished: {
                net._parseActiveConnections(text);
            }
        }
    }
}
