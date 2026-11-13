# Tailscale

`modules.nixos.tailscale` enables Tailscale. Supply enrollment and interface-specific firewall access rules separately through upstream options.

Set `services.tailscale.serveConfig` to the complete native `ServeConfig` JSON object, expressed as Nix attributes. Hosts own their routes and DNS names; application modules own their local listeners. The node must already be enrolled, with certificate provisioning enabled in the tailnet for HTTPS.

The `tailscale-serve` system service applies the configuration on boot, Tailscale restarts, and configuration changes. It replaces all Serve and Funnel settings, removing undeclared entries without a separate reset. Manual changes last until the service next applies the declaration. This uses Tailscale's undocumented `serve set-raw` command; the documented `serve set-config` only manages named Tailscale Services, not node routes.

The default `null` leaves Serve unmanaged. Set `{}` and activate to clear all mappings before removing management. Stopping or removing the unit alone leaves Tailscale's persisted settings intact.
