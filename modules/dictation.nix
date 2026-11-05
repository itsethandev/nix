{inputs, ...}: {
  flake.modules.homeManager.dictation = {
    config,
    lib,
    ...
  }: let
    hex = config.programs.hex.package;
    bind = chord: action: flags: {
      _args = [
        chord
        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} "${lib.getExe hex} dictation ${action}"})")
        flags
      ];
    };
  in {
    imports = [inputs.hex.homeManagerModules.hex];

    programs.hex = {
      enable = lib.mkDefault true;
      autostart = lib.mkDefault true;
      model = lib.mkDefault "parakeet_unified_en";
      language = lib.mkDefault "en";
      installModel = lib.mkDefault true;
      settings.paste_with_shift = lib.mkDefault true;
      settings = {
        "labs.live_text" = true;
        "labs.spoken_formatting" = true;
        "labs.spoken_symbols" = true;
        "labs.filler_words" = true;
      };
    };

    wayland.windowManager.hyprland = lib.mkIf config.wayland.windowManager.hyprland.enable {
      configType = lib.mkDefault "lua";
      settings.bind = lib.mkOrder 1100 [
        (bind "SUPER + D" "start" {})
        (bind "SUPER + SHIFT + D" "toggle" {})
        (bind "SUPER + CTRL + D" "cancel" {})
        (bind "SUPER + D" "stop" {release = true;})
      ];
    };
  };
}
