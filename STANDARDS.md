# Project standards

These standards guide how this project is structured, maintained, and edited.

## Architecture

### Organize around complete features

A feature owns its related system configuration, Home Manager configuration, packages, and optional integrations. Follow behavior rather than upstream module classes or arbitrary file-size limits.

Features, hosts, and development shells may span multiple files within their owning folder. Split around coherent roles when it makes behavior easier to find and understand. Prefer role-based filenames, and keep each behavior's settings, dependencies, and shortcuts together.

### Use the dendritic pattern consistently

Every Nix file except `flake.nix` is an automatically imported flake-parts module. Store lower-level modules as typed option values. File locations organize concepts rather than control evaluation.

Consumable folders have these output contracts:

- Features export at least one module through `flake.modules.nixos`, `flake.modules.darwin`, or `flake.modules.homeManager`. They may also define feature-owned overlays and `perSystem.packages`, but not deployments or deployment fragments.
- Hosts export at least one `flake.nixosConfigurations` or `flake.darwinConfigurations` deployment. Their typed `nixos` and `darwin` fragments match their respective deployment names; `home` fragments belong to deployments in the same folder. Hosts do not publish reusable features, packages, overlays, or shells.
- Development shells define at least one `perSystem.devShells` output across the configured systems, without publishing features, packages, overlays, or deployments.

Check these contracts across all Nix files in the owning folder. Export names need not match folder names. Root-level files in `modules/` provide shared structural plumbing rather than consumable features.

### Separate capabilities from deployment choices

Reusable features must not name hosts, users, or machine-specific resources. Host directories select capabilities and supply identities, destinations, access rules, and hardware settings.

### Make consumption explicit

Importing a lower-level feature module selects its behavior. Avoid repository-specific enable wrappers. Registering an exported module must not activate it in a deployment.

### Keep dependencies explicit and self-contained

Features own their package dependencies and must work without the repository's default overlay. Capture shared inputs at the flake-parts level rather than passing them through `specialArgs`.

### Apply the deletion test

Removing a feature and its explicit references—including caller settings—must leave unrelated features working without further edits. A feature must also work independently with its documented prerequisites.

### Keep optional integrations optional

Integrate with another capability only when it is independently selected. Do not silently activate another repository feature to satisfy an integration.

## Design and maintenance

### Keep module READMEs minimal and current

Each consumable feature, host, and development shell has a colocated `README.md`. Describe what selecting it enables, installs, or changes, with supported platforms and caller prerequisites where relevant. Include only enough to understand its effects; omit implementation narration, plans, and history. Update the README alongside behavior changes. Structural plumbing and private configuration fragments do not need separate READMEs.

### Abstractions must earn their place

Introduce an abstraction when it hides meaningful decisions or coordinates coherent behavior—not merely to rename upstream options, shorten a file, or anticipate hypothetical reuse.

### Prefer upstream interfaces

Use upstream options for caller configuration. Add repository options only for genuine inputs that upstream interfaces cannot express clearly. Keep defaults overridable without making the feature inconsistent.

### Simplify within the task

Design changes as coherent parts of the system rather than additions bolted onto existing behavior. Remove unnecessary complexity, but avoid unrelated rewrites and speculative flexibility.

### Keep configuration declarative and reproducible

Derive managed state from repository content and locked inputs. Avoid ambient machine identity, undeclared files, and evaluation-time side effects. Keep plaintext secrets outside the repository.

## Editing and verification

### Verify claims directly

Format changed Nix and evaluate affected outputs. Use targeted builds or behavioral verification where evaluation is insufficient. State platform limitations and unverified behavior explicitly.

### Test architectural contracts, not configuration choices

Repository tests enforce documented structural contracts: module interfaces, output namespaces and types, ownership boundaries, and mechanically checkable conventions. Discover features, hosts, and shells rather than maintaining expected inventories. A valid change to selected capabilities, packages, identities, hardware, or settings must not require changing test expectations unless an architectural contract changes. Use fixtures only to exercise a contract, with the minimum configuration needed. Keep checks deterministic.

### Keep conventions simple

Use lowercase kebab-case for configuration files and directories, lower camelCase for option names, and Alejandra for Nix formatting. Write comments that explain otherwise non-obvious constraints.
