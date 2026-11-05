{
  home.turing = {
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
    xdg = {
      desktopEntries = {
        nemo = {
          name = "Nemo";
          exec = lib.getExe' pkgs.nemo-with-extensions "nemo";
        };
        pick-color = {
          name = "Pick Color";
          comment = "Pick a screen color and copy it to the clipboard";
          exec = lib.getExe pickColor;
          terminal = false;
          startupNotify = false;
          categories = ["Utility"];
          settings.Keywords = "color;picker;eyedropper;clipboard;";
        };
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = ["nemo.desktop"];
          "application/x-gnome-saved-search" = ["nemo.desktop"];
        };
      };
      userDirs = {
        enable = true;
        setSessionVariables = false;
      };
    };
  };
}
