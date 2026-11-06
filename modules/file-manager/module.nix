{
  flake.modules.homeManager.file-manager = {
    lib,
    pkgs,
    ...
  }: {
    xdg = {
      desktopEntries.nemo = {
        name = "Nemo";
        exec = lib.getExe' pkgs.nemo-with-extensions "nemo";
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = ["nemo.desktop"];
          "application/x-gnome-saved-search" = ["nemo.desktop"];
        };
      };
    };
  };
}
