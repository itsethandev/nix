{
  flake.modules.homeManager.color-picker = {
    lib,
    pkgs,
    ...
  }: let
    pickColor = pkgs.writeShellApplication {
      name = "pick-color";
      runtimeInputs = [pkgs.hyprpicker pkgs.wl-clipboard];
      text = ''
        hyprpicker --format hex | wl-copy
      '';
    };
  in {
    xdg.desktopEntries.pick-color = {
      name = "Pick Color";
      comment = "Pick a screen color and copy it to the clipboard";
      exec = lib.getExe pickColor;
      terminal = false;
      startupNotify = false;
      categories = ["Utility"];
      settings.Keywords = "color;picker;eyedropper;clipboard;";
    };
  };
}
