{
  flake.modules.nixos.remote-browser = {
    lib,
    pkgs,
    ...
  }: let
    passwordFile = "/var/lib/remote-browser/password";
    initializePassword = pkgs.writeShellApplication {
      name = "remote-browser-password";
      runtimeInputs = [pkgs.coreutils pkgs.openssl];
      text = ''
        umask 077
        if [ ! -s ${passwordFile} ]; then
          password="$(openssl rand -base64 32)"
        else
          password="$(cat ${passwordFile})"
        fi
        # FILE__PASSWORD preserves newlines, so normalize existing files as well.
        printf '%s' "$password" > ${passwordFile}
      '';
    };
  in {
    virtualisation.oci-containers = {
      backend = "docker";
      containers.remote-browser = {
        # LinuxServer Chromium 7b8e918f-ls63, built 2026-11-11.
        image = "ghcr.io/linuxserver/chromium@sha256:ff1b8235e20367c3b660d31892e14428687df75e2d62e274b7d8d40cf5537108";
        serviceName = "remote-browser";
        environment = {
          CUSTOM_USER = "browser";
          FILE__PASSWORD = "/run/secrets/browser-password";
          CUSTOM_WS_PORT = "6082";
          SELKIES_ENABLE_BASIC_AUTH = "true";
          TITLE = "Remote browser";
          CHROME_CLI = "about:blank";
          HARDEN_DESKTOP = "true";
          RESTART_APP = "true";
          START_DOCKER = "false";
        };
        volumes = [
          "remote-browser:/config"
          "${passwordFile}:/run/secrets/browser-password:ro"
          "${./nginx.conf}:/defaults/default.conf:ro"
        ];
        extraOptions = [
          "--network=host"
          "--shm-size=1g"
        ];
      };
    };

    systemd.services.remote-browser.serviceConfig = {
      StateDirectory = "remote-browser";
      StateDirectoryMode = "0700";
      ExecStartPre = lib.mkBefore [(lib.getExe initializePassword)];
    };
  };
}
