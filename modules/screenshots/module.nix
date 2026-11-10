{lib, ...}: let
  package = {pkgs, ...}:
    pkgs.stdenv.mkDerivation {
      pname = "omasnap";
      version = "1.25.0";

      src = pkgs.fetchFromGitHub {
        owner = "omacom";
        repo = "omasnap";
        rev = "008a3d1ecb8c67b6709ff2fbcd6da1290b2944ee";
        hash = "sha256-tFnTqAGKmNHQqjPsBq/XvgRh/5jXiD0Mxj6h1SLEpyI=";
      };

      nativeBuildInputs = with pkgs; [cmake ninja pkg-config qt6.wrapQtAppsHook wayland-scanner];
      buildInputs = with pkgs; [qt6.qtbase qt6.qtwayland kdePackages.layer-shell-qt wayland libdeflate];
      nativeCheckInputs = [pkgs.tesseract];

      postPatch = ''
        substituteInPlace CMakeLists.txt \
          --replace-fail /usr/share/wayland-protocols ${pkgs.wayland-protocols}/share/wayland-protocols
        substituteInPlace tests/{clipboard-smoke,transform-smoke,editor-smoke}.cpp \
          --replace-fail '#!/usr/bin/env bash' '#!${pkgs.bash}/bin/bash'
        substituteInPlace tests/pin-interaction-smoke.cpp \
          --replace-fail /bin/cat ${pkgs.coreutils}/bin/cat
      '';

      doCheck = true;
      preCheck = ''
        export HOME="$TMPDIR/home"
        export XDG_RUNTIME_DIR="$TMPDIR/runtime"
        mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
        export FONTCONFIG_FILE=${pkgs.makeFontsConf {
          fontDirectories = [pkgs.dejavu_fonts];
          includes = ["${pkgs.fontconfig.out}/etc/fonts/conf.d"];
        }}
        export QT_QPA_PLATFORM=offscreen
      '';
      checkPhase = ''
        runHook preCheck
        ./omasnap-smoke
        runHook postCheck
      '';

      qtWrapperArgs = [
        "--prefix PATH : ${lib.makeBinPath (with pkgs; [hyprland wl-clipboard tesseract xdg-utils])}"
      ];

      meta = {
        description = "Hyprland screenshot picker and annotation editor";
        homepage = "https://github.com/omacom/omasnap";
        license = lib.licenses.mit;
        mainProgram = "omasnap";
        platforms = lib.platforms.linux;
      };
    };
in {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.hasSuffix "-linux" system) {
      packages.omasnap = pkgs.callPackage package {};
    };

  flake.modules.homeManager.screenshots = {
    config,
    lib,
    pkgs,
    ...
  }: let
    omasnap = pkgs.callPackage package {};
  in {
    home.packages = [omasnap];
    wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
      bind = lib.mkAfter (map (binding: {
          _args = [binding.chord (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "${lib.getExe omasnap}${binding.arguments}"})")];
        }) [
          {
            chord = "SUPER + CTRL + P";
            arguments = " --capture-fullscreen";
          }
          {
            chord = "SUPER + CTRL + ALT + P";
            arguments = "";
          }
        ]);
      layer_rule = lib.mkAfter [
        {
          name = "omasnap";
          match.namespace = "^omasnap$";
          no_anim = true;
          animation = "none";
        }
      ];
    };
  };
}
