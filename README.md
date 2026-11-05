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

`modules/configurations.nix` declares `nixos`, `darwin`, and `home` as maps of deferred modules. Feature files contribute to these maps under deployment names. The module system merges those contributions, and `modules/hosts/` evaluates the complete deployments. Shared values and inputs are captured at the flake-parts level rather than threaded through module arguments.

Features own their packages and optional integrations alongside their configuration. Removing a feature file removes its contributions without leaving dangling imports. Host definitions, hardware definitions, and structural plumbing are required foundations rather than removable features.

`static/` contains non-secret assets. `packages/` contains npm source manifests and lockfiles consumed by feature modules. There are no maintained specifications or checks.

## Outputs

- `nixosConfigurations.turing` and `darwinConfigurations.newton`: complete deployments.
- `overlays`: package overrides and their default composition.
- `packages.<system>`: Linux packages maintained here.
- `devShells.<system>`: `js`, `lua`, `pi`, `python`, and `rust` development environments.

For example:

```sh
nix develop .#js
nix develop .#pi --command pi
```

Repository-specific agent procedures live in [AGENTS.md](AGENTS.md).
