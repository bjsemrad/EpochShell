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
      url = "path:/home/brian/projects/EpochOxide";
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
          default = epochshell;
        }
      );

      apps = forAllSystems (
        { system, ... }: {
          default = {
            type = "app";
            program = "${self.packages.${system}.epochshell}/bin/epochshell";
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
          imports = [ epochoxide.homeManagerModules.default ];

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
                    ];
                    description = "Runtime tools made available to EpochOxide providers.";
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
          };

          config = lib.mkIf cfg.enable {
            # Install quickshell runtime and your flake package (optional but nice to have)
            home.packages = [
              qsPkg
              epochRun
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

            # EpochOxide backend (launcher data providers) + its systemd user service
            programs.epochoxide.enable = lib.mkDefault cfg.epochoxide.enable;
            programs.epochoxide.enableService = lib.mkDefault cfg.epochoxide.enableService;
            programs.epochoxide.package = lib.mkDefault cfg.epochoxide.package;
            programs.epochoxide.socket = lib.mkDefault cfg.epochoxide.socket;
            programs.epochoxide.runtimePackages = lib.mkDefault cfg.epochoxide.runtimePackages;
            programs.epochoxide.settings = lib.mkIf (cfg.epochoxide.settings != { }) cfg.epochoxide.settings;

            # Autostart uses the HM wrapper so -c is guaranteed
            systemd.user.services.epochshell = lib.mkIf cfg.autostart {
              Unit = {
                Description = "EpochShell (Quickshell)";
                After = [ "graphical-session.target" ];
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
