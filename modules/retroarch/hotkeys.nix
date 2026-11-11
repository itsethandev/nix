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
      close_content = "start";
      exit_emulator = null;
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
          "$out" ${pkgs.writeText "retroarch-hotkeys.json" (builtins.toJSON bindings)} \
          ${./controllers}
      '';
  in {
    programs.retroarch.settings =
      {
        input_joypad_driver = "udev";
        input_autodetect_enable = "true";
        joypad_autoconfig_dir = "${profiles}";
        quit_on_close_content = "0";
      }
      // lib.listToAttrs (lib.concatMap (action:
        map (kind: lib.nameValuePair "input_${action}_${kind}" "nul") ["btn" "axis"])
      (builtins.attrNames bindings));
  };
}
