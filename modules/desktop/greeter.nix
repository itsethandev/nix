{inputs, ...}: {
  flake.modules.nixos.desktop = {config, ...}: let
    colors = config.lib.stylix.colors;
  in {
    imports = [inputs.noctalia-greeter.nixosModules.default];
    programs.noctalia-greeter = {
      enable = true;
      settings = {
        session.default = "Hyprland (uwsm-managed)";
        appearance = {
          scheme = "Synced";
          hide_logo = false;
          theme_mode =
            if config.stylix.polarity == "light"
            then "light"
            else "dark";
          font_family = config.stylix.fonts.sansSerif.name;
          wallpaper = {
            path = "${config.stylix.image}";
            fill_mode = "crop";
          };
          palette = with colors.withHashtag; {
            primary = base0D;
            on_primary = base00;
            secondary = base0E;
            on_secondary = base00;
            tertiary = base0C;
            on_tertiary = base00;
            error = base08;
            on_error = base00;
            surface = base00;
            on_surface = base05;
            surface_variant = base01;
            on_surface_variant = base04;
            outline = base03;
            shadow = base00;
            hover = base0C;
            on_hover = base00;
          };
        };
      };
    };
  };
}
