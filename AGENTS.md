# Agent instructions

Read [README.md](README.md) for repository structure and deployment commands.

## Configuration changes

- Every Nix file except `flake.nix` is a flake-parts module imported automatically from `modules/`.
- Organize modules by complete features, including their system, home, package, and integration definitions. Choose ownership from the behavior, not the upstream module class.
- Contribute lower-level modules through the typed `nixos`, `darwin`, and `home` options. Capture inputs and shared values in the top-level scope instead of passing `specialArgs` or `extraSpecialArgs`.
- Features activate through composition, without repository-specific enable options. Keep optional integrations conditional on the upstream feature being enabled.
- A feature file must be removable without edits elsewhere or failures in unrelated configuration. Host definitions, hardware definitions, and structural plumbing are exceptions.
- Read relevant Nix before editing. Keep definitions declarative and secrets outside plaintext source control.
- Use lowercase kebab-case filenames and lower camelCase option names. Format Nix with Alejandra.
- Keep the existing input pins unless an update is requested.
- This repository has no maintained specs or checks. Do not add them without a request.

## Verification

Evaluate affected flake outputs. For refactors, capture a baseline first and compare system and Home Manager derivations, generated files, and activation behavior as needed. Keep temporary verification artifacts outside the repository. Report exactly what was verified and any limitations. Never activate a system or push without an explicit request.

## Reusable skills

Reusable skill implementations belong in [ItsSkills](https://github.com/ItsEthanDev/its-skills). This repository owns the locked source input and discovery configuration, not those implementations.
