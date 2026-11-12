{
  flake.modules.homeManager.file-manager = {pkgs, ...}: {
    home.packages = [pkgs.nautilus];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
        "application/x-gnome-saved-search" = ["org.gnome.Nautilus.desktop"];
      };
    };
  };
}
