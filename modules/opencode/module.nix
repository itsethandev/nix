{inputs, ...}: let
  overlay = final: prev: {
    opencode = prev.opencode.overrideAttrs (finalAttrs: old: {
      version = "2.3.2";
      src = final.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v2.3.2";
        hash = "sha256-yEdLD000KJPNkuowiy4g+sHV+7dm3xazKTEf15ZIYKs=";
      };
      # Use the dependency hash verified with the pinned nixpkgs toolchain.
      node_modules = final.callPackage (finalAttrs.src + "/nix/node_modules.nix") (
        final.lib.optionalAttrs (final.stdenv.hostPlatform.system == "x86_64-linux") {
          hash = "sha256-TZJtdK3IULtOnbeYjrYZy9U47etQ63V7BplXGVstNPI=";
        }
      );
      installPhase =
        builtins.replaceStrings
        ["../web/public/theme.json"]
        ["../../services/site/public/v1/docs/theme.json"]
        old.installPhase;
    });
  };
in {
  flake.overlays.opencode = overlay;

  flake.modules.homeManager.opencode = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    opencodePkgs = pkgs.extend overlay;
  in {
    home.packages = [opencodePkgs.opencode-desktop];

    programs.opencode = {
      enable = lib.mkDefault true;
      package = opencodePkgs.opencode;
      # Pinned Stylix still selects its theme through the obsolete V1 setting.
      tui = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkForce {});
      cli = {
        attention.notifications = lib.mkDefault false;
        prompt.paste = lib.mkDefault "full";
        plugins = lib.mkIf config.programs.herdr.enable [
          "${config.xdg.configHome}/opencode/herdr-opencode"
        ];
        theme.name = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkDefault "stylix");
      };
      context = ../../static/ai/AGENTS.md;
      commands = ../../static/ai/prompts;
      skills = inputs.its-skills + "/skills";
      settings.plugins = ["opencode-mobile-notifications@0.1.2"];
      settings.permissions = lib.mkDefault [
        {
          action = "question";
          resource = "*";
          effect = "deny";
        }
        {
          action = "websearch";
          resource = "*";
          effect = "allow";
        }
        {
          action = "webfetch";
          resource = "*";
          effect = "allow";
        }
      ];
    };
  };
}
