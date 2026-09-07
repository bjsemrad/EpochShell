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

    elephant = {
      url = "github:abenz1267/elephant"; # "v2.22.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      quickshell,
      home-manager,
      elephant,
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
          elephant = elephant.packages.${system}.elephant-with-providers;
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

          # HM-generated wrapper that ALWAYS sets -c <user config dir>
          epochRun = pkgs.writeShellScriptBin "epochshell" ''
            set -euo pipefail

            CONFIG_HOME="''${XDG_CONFIG_HOME:-''${HOME}/.config}"
            CONFIG_DIR="$CONFIG_HOME/${cfg.configDir}"

            exec ${qsPkg}/bin/quickshell -c "$CONFIG_DIR" "$@"
          '';
        in
        {
          imports = [ elephant.homeManagerModules.default ];

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

            elephant = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Install and start the elephant launcher backend (systemd user service).";
                  };

                  installService = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Create a systemd user service for elephant.";
                  };

                  debug = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Enable debug logging for the elephant service.";
                  };

                  settings = lib.mkOption {
                    type = (pkgs.formats.toml { }).type;
                    default = { };
                    description = "elephant.toml settings. Run `elephant generatedoc` to view available options.";
                  };

                  providers = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    description = "List of built-in providers to install. Defaults to elephant's built-in set when empty.";
                  };

                  provider = lib.mkOption {
                    type = lib.types.attrsOf (
                      lib.types.submodule {
                        options.settings = lib.mkOption {
                          type = (pkgs.formats.toml { }).type;
                          default = { };
                          description = "Provider-specific TOML settings.";
                        };
                      }
                    );
                    default = { };
                    description = "Per-provider settings forwarded to XDG config.";
                  };
                };
              };
              default = { };
              description = "Elephant launcher backend shipped with EpochShell.";
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

            # Elephant backend (launcher data providers) + its systemd user service
            programs.elephant.enable = lib.mkDefault cfg.elephant.enable;
            programs.elephant.debug = lib.mkDefault cfg.elephant.debug;
            programs.elephant.settings = lib.mkIf (cfg.elephant.settings != { }) cfg.elephant.settings;
            programs.elephant.providers = lib.mkIf (cfg.elephant.providers != [ ]) cfg.elephant.providers;
            # Ship the keybinds menu (hypr + niri providers) with the shell
            programs.elephant.provider = cfg.elephant.provider
              // {
                menus = (cfg.elephant.provider.menus or { })
                  // {
                    lua = (cfg.elephant.provider.menus.lua or { })
                      // { keybinds = builtins.readFile "${self}/quickshell/menus/keybinds.lua"; };
                  };
              };
            programs.elephant.installService = lib.mkDefault cfg.elephant.installService;

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
