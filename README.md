# Ethan's Nix configuration

NixOS, nix-darwin, and Home Manager configurations using [flake-parts](https://flake.parts) and the [dendritic pattern](https://github.com/mightyiam/dendritic).

## Deploy

Use Nix with `flakes` and `nix-command` enabled and the target platform's rebuild tool:

```sh
sudo nixos-rebuild switch --flake .#turing
darwin-rebuild switch --flake .#newton
```

Home Manager is integrated into each system, so system and home generations change and roll back together.

## Structure

`flake.nix` declares locked inputs and imports `modules/` automatically with import-tree. Every other Nix file is a flake-parts module implementing one feature across the configurations it applies to. File paths name features; they do not determine module types or import relationships.

Feature files export portable modules through `modules.nixos`, `modules.darwin`, and `modules.homeManager` in the flake outputs. `modules/hosts/` selects those modules explicitly and supplies host names, users, Git identities, backup destinations, credentials paths, and hardware-specific values. The typed `nixos`, `darwin`, and `home` maps collect deployment definitions and hardware fragments. Shared values and inputs are captured at the flake-parts level rather than threaded through module arguments.

Features own their packages and optional integrations alongside their configuration. Removing a feature and its explicit selections and caller settings leaves unrelated features working without further edits. Exported modules do not select hosts or implicitly import other repository features. Linux-only capabilities still require Linux; modules spanning NixOS and Home Manager expose each implementation separately.

`static/` contains non-secret assets. `packages/` contains npm source manifests and lockfiles consumed by feature modules. There are no maintained specifications or checks.

## Consume a module

Add this flake as an input named `ethan`, then import the modules you want:

```nix
imports = [inputs.ethan.modules.nixos.backups];

services.restic.backups.documents = {
  repository = "/mnt/backups/documents";
  passwordFile = "/run/secrets/restic-password";
  paths = ["/srv/documents"];
};
```

The backup module supplies scheduling and retention defaults for each Restic job. It does not choose a repository, paths, or credentials. Other modules use upstream configuration options wherever possible. `file-sharing` additionally requires `fileSharing.user`, and `steam-frame` requires `steamFrame.countryCode` and `steamFrame.adapterMacAddress`. Callers supply the user account for file sharing and may override `services.samba.settings.public.path`.

Home Manager consumers can import modules such as `inputs.ethan.modules.homeManager.terminal` directly, whether standalone or integrated with a system. Custom package dependencies are included by the feature; consumers do not need the default overlay. Stylix integrations apply when the caller independently imports and enables Stylix.

## Outputs

- `nixosConfigurations.turing` and `darwinConfigurations.newton`: complete deployments.
- `modules.<class>.<feature>`: independently consumable NixOS, nix-darwin, and Home Manager modules.
- `overlays`: package overrides and their default composition.
- `packages.<system>`: Linux packages maintained here.
- `devShells.<system>`: `js`, `lua`, `pi`, `python`, and `rust` development environments.

For example:

```sh
nix develop .#js
nix develop .#pi --command pi
```

Project design and maintenance rules live in [STANDARDS.md](STANDARDS.md). Repository-specific agent procedures live in [AGENTS.md](AGENTS.md).
