{
  description = "EpochShell: a Quickshell-based shell with a nix flake + HM module";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    epochoxide = {
      url = "github:bjsemrad/epochoxide";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    epochctl = {
      url = "github:bjsemrad/epochctl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      quickshell,
      home-manager,
      epochoxide,
      epochctl,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      # -----------------------
      # Packages
      # -----------------------
      packages = forAllSystems (
        { system, pkgs }:
        let
          qs = quickshell.packages.${system}.default;

          epochshell = pkgs.writeShellScriptBin "epochshell" ''
            exec ${qs}/bin/quickshell "$@"
          '';
        in
        {
          quickshell = qs;
          epochshell = epochshell;
          epochoxide = epochoxide.packages.${system}.default;
          epochctl = epochctl.packages.${system}.default;
          default = epochshell;
        }
      );

      # -----------------------
      # Apps: things to run straight from the flake, without installing anything
      # -----------------------
      apps = forAllSystems (
        { system, pkgs }:
        let
          ctl = "${epochctl.packages.${system}.default}/bin/epochctl";
          qs = quickshell.packages.${system}.default;

          # Quickshell against this repo's config rather than whatever is installed. The point of
          # this one is trying EpochShell without touching a running session, so it says what it
          # is about to do about the shell that is probably already running.
          preview = pkgs.writeShellScript "epochshell-preview" ''
            set -eu
            config=''${1:-${self}/quickshell}
            echo "EpochShell preview: $config"
            if ${pkgs.systemd}/bin/systemctl --user is-active --quiet epochshell.service 2>/dev/null; then
              echo "note: epochshell.service is running; this preview will draw a second bar."
              echo "      stop it first with: systemctl --user stop epochshell.service"
            fi
            exec ${qs}/bin/quickshell -c "$config"
          '';

          # Every file a typo can silently disable. TOML that fails to parse is skipped at load
          # time and the shell falls back to defaults, which looks like the setting not working
          # rather than the file being wrong -- so this says so out loud.
          checkConfig = pkgs.writeShellScript "epochshell-check-config" ''
            set -u
            status=0
            check() {
              if [ ! -e "$1" ]; then
                echo "  --    $1 (not present)"
                return 0
              fi
              if ${pkgs.python3}/bin/python3 -c "import sys,tomllib;tomllib.load(open(sys.argv[1],'rb'))" "$1" 2>/tmp/epochshell-toml-err; then
                echo "  ok    $1"
              else
                echo "  FAIL  $1"
                sed 's/^/        /' /tmp/epochshell-toml-err
                status=1
              fi
            }
            config_home=''${XDG_CONFIG_HOME:-$HOME/.config}
            echo "Shell theme overrides:"
            check "$config_home/epochshell/config.toml"
            echo "EpochOxide:"
            check "$config_home/epochoxide/config.toml"
            echo "Launcher menus:"
            found=0
            for menu in "$config_home"/epochoxide/menus/*.toml; do
              [ -e "$menu" ] || continue
              found=1
              check "$menu"
            done
            [ "$found" = 1 ] || echo "  --    no menus installed"
            rm -f /tmp/epochshell-toml-err
            exit $status
          '';
        in
        {
          default = {
            type = "app";
            program = "${self.packages.${system}.epochshell}/bin/epochshell";
          };

          # Diagnose a session: the shell, the backend, and the tools they need.
          doctor = {
            type = "app";
            program = "${pkgs.writeShellScript "epochshell-doctor" ''exec ${ctl} doctor "$@"''}";
          };

          # Try this checkout without installing it.
          preview = {
            type = "app";
            program = "${preview}";
          };

          # Parse every config file before a rebuild turns a typo into silent defaults.
          check-config = {
            type = "app";
            program = "${checkConfig}";
          };

          reload = {
            type = "app";
            program = "${pkgs.writeShellScript "epochshell-reload" ''exec ${ctl} reload "$@"''}";
          };
        }
      );

      # -----------------------
      # Home Manager module
      # -----------------------
      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.epochshell;

          # From your flake packages
          epochPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.epochshell;
          qsPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
          epochoxidePkg = epochoxide.packages.${pkgs.stdenv.hostPlatform.system}.default;
          epochctlPkg = epochctl.packages.${pkgs.stdenv.hostPlatform.system}.default;

          # Tools the launcher's file-preview pane shells out to for formats Qt can't decode
          # natively here (no HEIF plugin in nixpkgs' qtimageformats; qtimageformats itself isn't
          # on quickshell's wrapped plugin path, so even webp/tiff/avif need a fallback).
          defaultRuntimePackages = pkgs: with pkgs; [
            poppler-utils # pdftoppm — PDF preview thumbnails
            imagemagick # convert — general raster preview thumbnails (HEIC/HEIF included)
          ];
          runtimePath = lib.makeBinPath cfg.runtimePackages;

          # HM-generated wrapper that ALWAYS sets -c <user config dir>
          epochRun = pkgs.writeShellScriptBin "epochshell" ''
            set -euo pipefail

            export PATH="${runtimePath}:$PATH"
            CONFIG_HOME="''${XDG_CONFIG_HOME:-''${HOME}/.config}"
            CONFIG_DIR="$CONFIG_HOME/${cfg.configDir}"

            exec ${qsPkg}/bin/quickshell -c "$CONFIG_DIR" "$@"
          '';
        in
        {
          imports = [
            epochoxide.homeManagerModules.default
            epochctl.homeManagerModules.default
          ];

          options.programs.epochshell = {
            enable = lib.mkEnableOption "EpochShell (runs Quickshell)";

            configDir = lib.mkOption {
              type = lib.types.str;
              default = "epochshell";
              description = "Directory under XDG config home containing the EpochShell config.";
            };

            autostart = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Start EpochShell (quickshell) via systemd --user.";
            };

            runtimePackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = defaultRuntimePackages pkgs;
              description = "Runtime tools made available to the shell process (e.g. launcher file-preview thumbnailers).";
            };

            nixUpdates = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  enable = lib.mkEnableOption "flake update awareness in the shell";

                  flake = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    example = "~/nixconfig";
                    description = ''
                      Flake to watch for input updates. Checking never writes to it: the inputs are
                      resolved into a throwaway lock file and compared, so flake.lock is left alone.
                    '';
                  };

                  checkIntervalMinutes = lib.mkOption {
                    type = lib.types.int;
                    default = 60;
                    description = "Minutes between automatic checks. Zero leaves only manual ones.";
                  };

                  updateCommand = lib.mkOption {
                    type = lib.types.str;
                    default = "nix flake update";
                    description = ''
                      Command the update action runs in a terminal, from the flake's directory.
                      It runs through your login shell interactively, so an alias works here.
                    '';
                  };

                  rebuildCommand = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    example = "sudo nixos-rebuild switch --flake .#%HOST%";
                    description = ''
                      Fallback rebuild command for hosts read out of the flake, with %HOST%
                      replaced by the host name. Empty means those hosts are offered no rebuild
                      action at all, which is the default: guessing a rebuild command means running
                      the wrong one on someone's machine.
                    '';
                  };

                  hosts = lib.mkOption {
                    type = lib.types.listOf (
                      lib.types.submodule {
                        options = {
                          name = lib.mkOption {
                            type = lib.types.str;
                            description = "Host name, as nixosConfigurations calls it.";
                          };
                          rebuild = lib.mkOption {
                            type = lib.types.str;
                            default = "";
                            description = "What rebuilds this host. Empty falls back to rebuildCommand.";
                          };
                        };
                      }
                    );
                    default = [ ];
                    example = [
                      {
                        name = "thor";
                        rebuild = "nixswitch";
                      }
                    ];
                    description = ''
                      Hosts to offer a rebuild for, each with its own command. Per host rather than
                      one template because a rebuild is usually an alias or a script that already
                      knows its target. Empty reads the names from the flake.
                    '';
                  };

                  notify = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Notify when an input gains an update it did not have last check.";
                  };
                };
              };
              default = { };
              description = "Nix flake update awareness, shown in the shell's Nix panel.";
            };

            homeAssistant = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  enable = lib.mkEnableOption "Home Assistant panel";

                  baseUrl = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Base URL for Home Assistant, for example http://homeassistant.local:8123.";
                  };

                  tokenFile = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Runtime path to a file containing a Home Assistant long-lived access token.";
                  };

                  favorites = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    description = "Home Assistant entity IDs to show in the EpochShell panel.";
                  };
                };
              };
              default = { };
              description = "Home Assistant panel configuration.";
            };

            epochoxide = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Install and start the EpochOxide launcher backend (systemd user service).";
                  };

                  enableService = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Create a systemd user service for EpochOxide.";
                  };

                  package = lib.mkOption {
                    type = lib.types.package;
                    default = epochoxidePkg;
                    description = "EpochOxide package to install and run.";
                  };

                  socket = lib.mkOption {
                    type = lib.types.str;
                    default = "%t/epochoxide.sock";
                    description = "EpochOxide socket path for the user service. %t expands to XDG_RUNTIME_DIR.";
                  };

                  runtimePackages = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = with pkgs; [
                      wl-clipboard
                      xclip
                      xdg-utils
                      wmctrl
                      tesseract
                      libqalculate
                      imagemagick
                      librsvg
                      fd
                      # Capture. grim, slurp and wf-recorder are wlroots screencopy tools rather
                      # than compositor-specific ones, so the same set serves Hyprland, niri, and
                      # sway. libnotify supplies notify-send, which is how a finished capture
                      # reaches this shell's own notification server. tesseract, listed above for
                      # clipboard OCR, also backs the capture panel's OCR row.
                      grim
                      slurp
                      wf-recorder
                      libnotify
                      # Night mode: holds a wlr-gamma-control object while it runs. hyprsunset
                      # works on niri too, which implements the same protocol.
                      hyprsunset
                      gammastep
                    ];
                    description = "Runtime tools made available to EpochOxide providers and capture.";
                  };

                  settings = lib.mkOption {
                    type = (pkgs.formats.toml { }).type;
                    default = { };
                    description = "EpochOxide config.toml settings.";
                  };
                };
              };
              default = { };
              description = "EpochOxide launcher backend shipped with EpochShell.";
            };

            epochctl = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Install epochctl, the control CLI for this shell.";
                  };

                  package = lib.mkOption {
                    type = lib.types.package;
                    default = epochctlPkg;
                    description = "epochctl package to install.";
                  };
                };
              };
              default = { };
              description = ''
                epochctl, the command keybindings and scripts should call instead of raw
                `qs ipc`. It is pointed at this module's own config directory and EpochOxide
                socket, so the two cannot drift apart.
              '';
            };
          };

          config = lib.mkIf cfg.enable {
            # Install quickshell runtime and your flake package (optional but nice to have)
            home.packages = [
              qsPkg
              epochRun
              # notify-send. EpochShell is the notification *server*; this is the client that
              # talks to it, and it is what EpochOxide's capture and any user keybinding or
              # script reach for. Installing it in the profile rather than only on the daemon's
              # PATH means `notify-send` works from a terminal too.
              pkgs.libnotify
            ];

            # Install repo config into ~/.config/${cfg.configDir}
            xdg.configFile."${cfg.configDir}".source = "${self}/quickshell";

            home.activation.epochshellHomeAssistantConfig = lib.mkIf cfg.homeAssistant.enable (
              lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                config_home="''${XDG_CONFIG_HOME:-''${HOME}/.config}"
                config_file="$config_home/epochshell-hass.json"
                token_file=${lib.escapeShellArg (if cfg.homeAssistant.tokenFile == null then "" else cfg.homeAssistant.tokenFile)}
                base_url=${lib.escapeShellArg cfg.homeAssistant.baseUrl}

                if [ -z "$token_file" ]; then
                  echo "epochshell: programs.epochshell.homeAssistant.tokenFile is required when enabled" >&2
                  exit 1
                fi

                if [ -z "$base_url" ]; then
                  echo "epochshell: programs.epochshell.homeAssistant.baseUrl is required when enabled" >&2
                  exit 1
                fi

                if [ ! -r "$token_file" ]; then
                  echo "epochshell: Home Assistant token file is not readable: $token_file" >&2
                  exit 1
                fi

                mkdir -p "$config_home"
                export EPOCHSHELL_HASS_BASE_URL="$base_url"
                export EPOCHSHELL_HASS_FAVORITES=${lib.escapeShellArg (builtins.toJSON cfg.homeAssistant.favorites)}
                export EPOCHSHELL_HASS_TOKEN="$(tr -d '\n' < "$token_file")"

                ${pkgs.python3}/bin/python3 -c '
import json
import os
import sys

path = sys.argv[1]
data = {
    "baseUrl": os.environ.get("EPOCHSHELL_HASS_BASE_URL", ""),
    "token": os.environ.get("EPOCHSHELL_HASS_TOKEN", ""),
    "favorites": json.loads(os.environ.get("EPOCHSHELL_HASS_FAVORITES", "[]")),
}
tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
os.chmod(tmp, 0o600)
os.replace(tmp, path)
' "$config_file"
              ''
            );

            # epochctl control CLI. Both paths are derived from this module rather than left to
            # epochctl's own defaults: configDir follows cfg.configDir, and the socket is the one
            # EpochOxide was told to use, with systemd's %t specifier resolved because a session
            # environment variable is not a unit file.
            programs.epochctl.enable = lib.mkDefault cfg.epochctl.enable;
            programs.epochctl.package = lib.mkDefault cfg.epochctl.package;
            programs.epochctl.configDir = lib.mkDefault "${config.xdg.configHome}/${cfg.configDir}";
            programs.epochctl.socket = lib.mkDefault (
              lib.replaceStrings [ "%t" ] [ "$XDG_RUNTIME_DIR" ] cfg.epochoxide.socket
            );

            # EpochOxide backend (launcher data providers) + its systemd user service
            programs.epochoxide.enable = lib.mkDefault cfg.epochoxide.enable;
            programs.epochoxide.enableService = lib.mkDefault cfg.epochoxide.enableService;
            programs.epochoxide.package = lib.mkDefault cfg.epochoxide.package;
            programs.epochoxide.socket = lib.mkDefault cfg.epochoxide.socket;
            programs.epochoxide.runtimePackages = lib.mkDefault cfg.epochoxide.runtimePackages;
            # Nix awareness is EpochOxide's job -- it owns the timer, the cache and the commands --
            # so these options are folded into its settings rather than being a second config file.
            # Anything set directly in epochoxide.settings still wins.
            programs.epochoxide.settings =
              let
                nixSettings = lib.optionalAttrs cfg.nixUpdates.enable {
                  nix_flake = cfg.nixUpdates.flake;
                  nix_check_interval_minutes = cfg.nixUpdates.checkIntervalMinutes;
                  nix_update_command = cfg.nixUpdates.updateCommand;
                  nix_rebuild_command = cfg.nixUpdates.rebuildCommand;
                  nix_hosts = cfg.nixUpdates.hosts;
                  nix_notify = cfg.nixUpdates.notify;
                };
                merged = nixSettings // cfg.epochoxide.settings;
              in
              lib.mkIf (merged != { }) merged;
            systemd.user.services.epochoxide.Unit = lib.mkIf cfg.epochoxide.enableService {
              X-Restart-Triggers = [ cfg.epochoxide.package ];
            };

            # Autostart uses the HM wrapper so -c is guaranteed
            systemd.user.services.epochshell = lib.mkIf cfg.autostart {
              Unit = {
                Description = "EpochShell (Quickshell)";
                After = [ "graphical-session.target" ];
                X-Restart-Triggers = [ "${self}/quickshell" ];
              };
              Service = {
                ExecStart = "${epochRun}/bin/epochshell";
                Restart = "always"; # "on-failure";
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
            };
          };
        };

      # Optional: a simple dev shell
      devShells = forAllSystems (
        { pkgs, system }: {
          default = pkgs.mkShell {
            packages = [
              self.packages.${system}.epochshell
              self.packages.${system}.quickshell
              pkgs.git
            ];
          };
        }
      );
    };
}
