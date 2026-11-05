{
  darwin.newton = {
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
  };
  home.turing = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.ghostty = {
      clearDefaultKeybinds = true;
      enable = true;
      enableFishIntegration = true;
      installBatSyntax = true;
      settings = {
        command = lib.mkIf config.programs.herdr.enable (lib.getExe config.programs.herdr.package);
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
      bind = lib.mkAfter [{_args = ["SUPER + Return" (lib.generators.mkLuaInline "hl.dsp.exec_cmd(${lib.generators.toLua {} (lib.getExe pkgs.ghostty)})")];}];
      window_rule = lib.mkAfter [
        {
          name = "ghostty-opacity";
          match.class = "com.mitchellh.ghostty";
          opacity = 0.875;
        }
      ];
    };

    systemd.user.services.herdr = lib.mkIf config.programs.herdr.enable {
      Unit = {
        Description = "Herdr graphical-session server";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "exec";
        ExecStart = let
          herdr = lib.getExe config.programs.herdr.package;
        in
          lib.getExe (pkgs.writeShellApplication {
            name = "herdr-session-server";
            text = ''
              server_running() {
                ${herdr} status server --json | ${lib.getExe pkgs.jq} -e '.running == true' >/dev/null
              }

              if server_running; then
                exit 0
              fi

              ${herdr} server || {
                status=$?
                if server_running; then
                  exit 0
                fi
                exit "$status"
              }
            '';
          });
        WorkingDirectory = config.home.homeDirectory;
        Restart = "on-failure";
        RestartSec = 3;
        Slice = "app-graphical.slice";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
