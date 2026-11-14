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
    options.services.tailscale.serveHostname = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;
      default = null;
      example = "host.example.ts.net";
      description = ''
        This node's Tailscale-assigned DNS name, required when httpsProxies is nonempty.
        Does not register DNS names or provision certificates for arbitrary domains.
      '';
    };

    options.services.tailscale.httpsProxies = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = {};
      example = {"443" = 7317;};
      description = ''
        External HTTPS ports mapped to local HTTP ports on 127.0.0.1, served at
        the root path of serveHostname. Generates entries in serveConfig, which
        can also declare additional native settings.
      '';
    };

    options.services.tailscale.serveConfig = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf json.type);
      default = null;
      description = ''
        Complete Tailscale Serve configuration in the native ServeConfig JSON format.
        Replaces all existing Serve and Funnel settings when applied. With no HTTPS
        proxies, null leaves settings unmanaged and an empty attribute set clears them.
        Requires an enrolled node and, for HTTPS, certificate provisioning enabled
        in the tailnet.
      '';
    };

    config = {
      assertions = [
        {
          assertion = cfg.httpsProxies == {} || cfg.serveHostname != null;
          message = "services.tailscale.serveHostname is required when httpsProxies is nonempty.";
        }
      ];

      services.tailscale.enable = true;
      services.tailscale.serveConfig = lib.mkIf (cfg.httpsProxies != {} && cfg.serveHostname != null) {
        TCP = lib.mapAttrs (_: _: {HTTPS = true;}) cfg.httpsProxies;
        Web = lib.mapAttrs' (port: localPort:
          lib.nameValuePair "${cfg.serveHostname}:${port}" {
            Handlers."/".Proxy = "http://127.0.0.1:${toString localPort}";
          })
        cfg.httpsProxies;
      };

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
