{
  flake.modules.homeManager.color-picker = {
    config,
    lib,
    pkgs,
    ...
  }: let
    pickColor = format:
      pkgs.writeShellApplication {
        name = "pick-color${lib.optionalString (format == "rgb") "-rgb"}";
        runtimeInputs = [pkgs.hyprpicker pkgs.wl-clipboard];
        text = ''
          exec hyprpicker --autocopy --no-fancy --format ${format} ${
            if format == "rgb"
            then "--output-format 'rgb({0}, {1}, {2})'"
            else "--lowercase-hex"
          }
        '';
      };
  in {
    xdg.desktopEntries.pick-color = {
      name = "Pick Color";
      comment = "Pick a screen color and copy it to the clipboard";
      exec = lib.getExe (pickColor "hex");
      terminal = false;
      startupNotify = false;
      categories = ["Utility"];
      settings.Keywords = "color;picker;eyedropper;clipboard;";
    };
    wayland.windowManager.hyprland.settings.bind = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter [
      {_args = ["SUPER + CTRL + C" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe (pickColor "hex"))})")];}
      {_args = ["SUPER + CTRL + ALT + C" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe (pickColor "rgb"))})")];}
    ]);
  };
}
