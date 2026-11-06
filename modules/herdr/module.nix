{
  flake.modules.homeManager.herdr = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libnotify];
    programs.herdr = {
      enable = lib.mkDefault true;
      settings = {
        keys = {
          navigate_workspace_down = lib.mkDefault "j";
          navigate_workspace_up = lib.mkDefault "k";
        };
        onboarding = lib.mkDefault false;
        terminal.default_shell = lib.mkDefault (lib.getExe pkgs.fish);
        theme.name = lib.mkDefault "terminal";
        ui.toast.delivery = lib.mkDefault "system";
      };
    };
    systemd.user.services.herdr = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.programs.herdr.enable) {
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
