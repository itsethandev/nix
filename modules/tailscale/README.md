# Tailscale

`modules.nixos.tailscale` enables Tailscale. Supply enrollment and interface-specific firewall access rules separately through upstream options.

Set `services.tailscale.serveHostname` to this node's Tailscale-assigned DNS name and declare root-path proxies with `httpsProxies`. Each entry maps an external HTTPS port to a local HTTP port on `127.0.0.1`:

```nix
services.tailscale = {
  serveHostname = "host.example.ts.net";
  httpsProxies = {
    "443" = 7317;
    "3000" = 3000;
  };
};
```

The hostname is required when proxies are declared; this module does not register DNS names or provision certificates for arbitrary domains. The node must already be enrolled, with certificate provisioning enabled in the tailnet for HTTPS.

The module generates the listeners and handlers in `services.tailscale.serveConfig`. That option also accepts native `ServeConfig` JSON settings expressed as Nix attributes for routes the shorthand does not cover. Hosts own their routes and DNS names; application modules own their local listeners.

The `tailscale-serve` system service applies the configuration on boot, Tailscale restarts, and configuration changes. It replaces all Serve and Funnel settings, removing undeclared entries without a separate reset. Manual changes last until the service next applies the declaration. This uses Tailscale's undocumented `serve set-raw` command; the documented `serve set-config` only manages named Tailscale Services, not node routes.

With no HTTPS proxies declared, the default `serveConfig = null` leaves Serve unmanaged. Remove all proxy declarations, set `serveConfig = {}`, and activate to clear all mappings before removing management. Stopping or removing the unit alone leaves Tailscale's persisted settings intact.
