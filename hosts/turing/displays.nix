{
  home.turing = {
    config,
    lib,
    pkgs,
    ...
  }: {
    wayland.windowManager.hyprland = {
      systemd.enable = false;
      settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
        config.misc.mouse_move_enables_dpms = true;
        on = lib.mkAfter [
          {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''function() hl.exec_cmd(${lib.generators.toLua {} "${lib.getExe pkgs.xrandr} --output DP-4 --primary"}) end'')
            ];
          }
        ];
        monitor = [
          {
            output = "DP-4";
            mode = "2560x1440@164.80";
            position = "1920x-360";
            scale = 1;
          }
          {
            output = "HDMI-A-1";
            mode = "1920x1080@60.00";
            position = "0x0";
            scale = 1;
          }
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];
        workspace_rule = map (number: {
          workspace = toString number;
          monitor =
            if number <= 5
            then "DP-4"
            else "HDMI-A-1";
          persistent = true;
          default = number == 1 || number == 6;
        }) (lib.range 1 10);
      };
    };
  };
}
