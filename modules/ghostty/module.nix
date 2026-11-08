{
  flake.modules.darwin.ghostty = {
    config,
    lib,
    ...
  }: {
    homebrew = {
      casks = ["ghostty"];
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    services.aerospace.settings.on-window-detected = lib.mkIf config.services.aerospace.enable [
      {
        "if".app-id = "com.mitchellh.ghostty";
        run = ["layout tiling"];
      }
    ];
    services.aerospace.settings.mode.main.binding."cmd-shift-enter" = lib.mkIf config.services.aerospace.enable (lib.mkDefault "exec-and-forget /usr/bin/open -na Ghostty");
  };
  flake.modules.homeManager.ghostty = {
    config,
    lib,
    ...
  }: {
    programs.ghostty = {
      clearDefaultKeybinds = true;
      enable = true;
      enableFishIntegration = true;
      installBatSyntax = true;
      settings = {
        command = lib.mkIf config.programs.fish.enable (lib.mkDefault (lib.getExe config.programs.fish.package));
        confirm-close-surface = false;
        copy-on-select = true;
        keybind = [
          "super+q=quit"
          "super+n=new_window"
          "ctrl+shift+,=reload_config"
          "shift+insert=paste_from_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+insert=copy_to_clipboard"
          "ctrl+shift+-=decrease_font_size:1"
          "ctrl+shift+==increase_font_size:1"
          "ctrl+shift+0=reset_font_size"
        ];
        quick-terminal-position = "center";
        quick-terminal-size = "90%,90%";
        selection-clear-on-copy = true;
        shell-integration = lib.mkIf config.programs.fish.enable "fish";
        window-padding-color = "extend";
        window-padding-x = 4;
        window-save-state = "always";
      };
    };

    wayland.windowManager.hyprland.settings = lib.mkIf config.wayland.windowManager.hyprland.enable {
      bind = lib.mkAfter (
        [{_args = ["SUPER + SHIFT + Return" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe config.programs.ghostty.package)})")];}]
        ++ lib.optional config.programs.herdr.enable {
          _args = ["SUPER + SHIFT + ALT + Return" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.escapeShellArgs [(lib.getExe config.programs.ghostty.package) "-e" (lib.getExe config.programs.herdr.package)])})")];
        }
      );
      window_rule = lib.mkAfter [
        {
          name = "ghostty-opacity";
          match.class = "com.mitchellh.ghostty";
          opacity = 0.875;
        }
      ];
    };
  };
}
