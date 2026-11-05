{lib, ...}: let
  package = {
    lib,
    pkgs,
    ...
  }:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "hyprzoom";
      version = "0.1.0";

      meta = {
        mainProgram = "hyprzoom";
        platforms = lib.platforms.linux;
      };

      dontUnpack = true;

      nativeBuildInputs = [
        pkgs.makeWrapper
      ];

      installPhase = ''
        install -Dm755 ${pkgs.writeShellScript "hyprzoom" ''
          if [ -z "$1" ]; then
            echo "Usage: $0 <delta>"
            exit 1
          fi

          if ! echo "$1" | ${lib.getExe pkgs.gnugrep} -Eq '^[+-]?[0-9]+(\.[0-9]+)?$'; then
            echo "Error: Delta must be a number"
            exit 1
          fi

          current=$(hyprctl getoption cursor:zoom_factor | head -n 1 | awk -F': ' '{print $2}')

          new_zoom=$(echo "$current * $1" | ${lib.getExe pkgs.bc})

          if [ "$(echo "$new_zoom < 1.0" | ${lib.getExe pkgs.bc})" -eq 1 ]; then
            new_zoom=1.0
          fi

          hyprctl eval "hl.config({ cursor = { zoom_factor = $new_zoom } })"
        ''} $out/bin/hyprzoom

        wrapProgram $out/bin/hyprzoom \
          --prefix PATH : ${
          lib.makeBinPath [
            pkgs.bc
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnugrep
            pkgs.hyprland
          ]
        }
      '';
    };
in {
  flake.overlays.hyprzoom = final: _prev: {hyprzoom = final.callPackage package {};};
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.hasSuffix "-linux" system) {
      packages.hyprzoom = pkgs.hyprzoom;
    };
  home.turing = {
    config,
    lib,
    pkgs,
    ...
  }: {
    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkOrder 1501 (map (binding: {
        _args = [binding.chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "${lib.getExe pkgs.hyprzoom} ${binding.factor}"})")];
      }) [
        {
          chord = "SUPER + mouse_down";
          factor = "0.8";
        }
        {
          chord = "SUPER + mouse_up";
          factor = "1.25";
        }
        {
          chord = "SUPER + mouse:274";
          factor = "0";
        }
      ]));
  };
}
