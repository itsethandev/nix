{
  flake.modules.homeManager.retroarch = {
    lib,
    pkgs,
    ...
  }: let
    bindings = {
      enable_hotkey = "select";
      rewind = "l2";
      hold_fast_forward = "r2";
      load_state = "l";
      save_state = "r";
      runahead_toggle = "up";
      exit_emulator = "start";
      menu_toggle = "x";
      fps_toggle = "y";
      reset = "b";
    };
    profiles =
      pkgs.runCommand "retroarch-hotkey-profiles" {
        nativeBuildInputs = [pkgs.python3];
      } ''
        python ${./hotkeys.py} \
          ${pkgs.retroarch-joypad-autoconfig}/share/libretro/autoconfig \
          "$out" ${pkgs.writeText "retroarch-hotkeys.json" (builtins.toJSON bindings)}
      '';
  in {
    programs.retroarch.settings =
      {
        input_joypad_driver = "udev";
        input_autodetect_enable = "true";
        joypad_autoconfig_dir = "${profiles}";
        rewind_enable = "true";
      }
      // lib.listToAttrs (lib.concatMap (action:
        map (kind: lib.nameValuePair "input_${action}_${kind}" "nul") ["btn" "axis"])
      (builtins.attrNames bindings));
  };
}
