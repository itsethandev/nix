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

`flake.nix` declares locked inputs and automatically imports every Nix file under `modules/`, `hosts/`, and `shells/` with import-tree. Those files are flake-parts modules. File paths organize features; they do not determine module types or import relationships.

Features in [`modules/`](modules/) export portable modules through `modules.nixos`, `modules.darwin`, and `modules.homeManager` in the flake outputs. [`hosts/`](hosts/) selects those modules explicitly and supplies host names, users, Git identities, backup destinations, credentials paths, and hardware-specific values. [`shells/`](shells/) defines development environments. Each feature, host, and shell has a short README describing its effects and prerequisites.

Feature and shell folders contain `module.nix`; host folders contain `configuration.nix`. Additional files group related concerns within the owning folder. `modules/configurations.nix` and `modules/nixpkgs.nix` provide shared plumbing. The typed `nixos`, `darwin`, and `home` maps collect deployment definitions and hardware fragments. Shared values and inputs are captured at the flake-parts level rather than threaded through module arguments.

Features own their packages and optional integrations alongside their configuration. Removing a feature and its explicit selections and caller settings leaves unrelated features working without further edits. Exported modules do not select hosts or implicitly import other repository features. Linux-only capabilities still require Linux; modules spanning NixOS and Home Manager expose each implementation separately.

Package source files live beside their consuming feature or shell. `static/` contains non-secret assets.

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
- `devShells.<system>`: `js`, `lua`, `python`, and `rust` development environments.
- `checks.<system>`: architectural contracts and Nix formatting.

For example:

```sh
nix develop .#js
```

The [`agent-tools`](modules/agent-tools/) Home Manager module installs shared CLI tools into the user environment for Pi, OpenCode, and ordinary terminal commands.

## Checks

Run the repository checks with:

```sh
nix flake check
```

The checks in `modules/checks.nix` discover consumable folders and evaluate each folder's Nix files together against its allowed output contract:

- `architecture-features`: typed module exports in supported classes, with optional feature-owned packages and overlays; no deployments or deployment fragments.
- `architecture-hosts`: deployment outputs with matching typed system fragments and no orphaned home fragments; no reusable feature or shell exports.
- `architecture-shells`: development-shell derivations, without feature or deployment outputs.
- `architecture-layout`: documented entrypoints and colocated READMEs, lowercase kebab-case configuration paths, and automatic import coverage.
- `formatting`: Alejandra formatting for configuration Nix files.

Package and shell derivations are evaluated for all configured systems, but their dependencies are not built and shell hooks are not executed. Host checks inspect deployment interfaces, not host settings or activation behavior. Exported feature bodies remain deferred; these checks do not prove independent consumption or runtime behavior. Package source files and assets are outside configuration naming checks unless they contain Nix configuration files.

To also ask Nix to validate every system's flake outputs without building checks:

```sh
nix flake check --all-systems --no-build
```

Project design and maintenance rules live in [STANDARDS.md](STANDARDS.md). Repository-specific agent procedures live in [AGENTS.md](AGENTS.md).
