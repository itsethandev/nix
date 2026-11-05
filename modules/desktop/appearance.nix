{inputs, ...}: {
  flake.modules.homeManager.desktop = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: {
    gtk.enable = true;
    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      x11.enable = true;
      hyprcursor.enable = true;
      name = "Banana";
      package = pkgs.banana-cursor;
      size = 24;
    };
    programs.noctalia.settings.shell.font_family = lib.mkIf (options ? stylix.enable && config.stylix.enable) (lib.mkDefault config.stylix.fonts.sansSerif.name);
  };
  flake.modules.nixos.desktop = {
    config,
    pkgs,
    ...
  }: let
    colors = config.lib.stylix.colors;
    mandelbrust = inputs.mandelbrust.packages.${pkgs.stdenv.hostPlatform.system}.default;
    wallpaper = pkgs.runCommand "mandelbrust-spirals-wallpaper.png" {} ''
      ${mandelbrust}/bin/mandelbrust render \
        --preset spirals \
        --size 3840x2160 \
        --outside-color ${colors.base05} \
        --inside-color ${colors.base01} \
        --output "$out" \
        --quiet
    '';
  in {
    programs.noctalia-greeter.settings.appearance.wallpaper = {
      path = "${wallpaper}";
      fill_mode = "crop";
    };
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/espresso.yaml";
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Mono";
        };
        sizes.terminal = 16;
      };
      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        light = "Papirus-Light";
        dark = "Papirus-Dark";
      };
      image = wallpaper;
    };
  };
}
