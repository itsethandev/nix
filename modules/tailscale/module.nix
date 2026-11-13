{
  flake.modules.nixos.tailscale = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.tailscale;
    json = pkgs.formats.json {};
    serveConfig = json.generate "tailscale-serve.json" cfg.serveConfig;
  in {
    options.services.tailscale.serveConfig = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf json.type);
      default = null;
      description = ''
        Complete Tailscale Serve configuration in the native ServeConfig JSON format.
        Replaces all existing Serve and Funnel settings when applied. Null leaves
        settings unmanaged; an empty attribute set clears them. Requires an enrolled
        node and, for HTTPS, certificate provisioning enabled in the tailnet.
      '';
    };

    config = {
      services.tailscale.enable = true;

      systemd.services.tailscale-serve = lib.mkIf (cfg.serveConfig != null) {
        description = "Apply declarative Tailscale Serve configuration";
        after = ["tailscaled.service" "tailscaled-autoconnect.service"];
        requires = ["tailscaled.service"];
        partOf = ["tailscaled.service"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = 5;
        };
        # set-config only handles named Services; set-raw also replaces node routes.
        script = ''
          ${lib.getExe cfg.package} serve set-raw < ${serveConfig}
        '';
      };
    };
  };
}
