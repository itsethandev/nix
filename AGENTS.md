# Agent instructions

Read [README.md](README.md) for repository structure and deployment commands.

## Configuration changes

- Every Nix file except `flake.nix` is a flake-parts module imported automatically from `modules/`.
- Organize modules by complete features, including their system, home, package, and integration definitions. Choose ownership from the behavior, not the upstream module class.
- Export portable lower-level modules through `flake.modules.nixos`, `flake.modules.darwin`, and `flake.modules.homeManager`. Keep host selection and deployment-specific values in `modules/hosts/`, composed through the typed `nixos`, `darwin`, and `home` options. Capture inputs and shared values in the top-level scope instead of passing `specialArgs` or `extraSpecialArgs`.
- Features activate through composition, without repository-specific enable options. Keep optional integrations conditional on the upstream feature being enabled.
- Apply the deletion test by removing a feature and its explicit references, including caller settings. Unrelated features must still work without further edits. Each exported module must also work independently with its caller-supplied prerequisites and upstream modules, without implicit imports of other repository features.
- Feature modules must not name deployment hosts or users. Use upstream options for caller settings; declare a small additional interface only when the feature needs inputs that upstream options cannot express. Package dependencies must work without the repository's default overlay.
- Read relevant Nix before editing. Keep definitions declarative and secrets outside plaintext source control.
- Use lowercase kebab-case filenames and lower camelCase option names. Format Nix with Alejandra.
- Keep the existing input pins unless an update is requested.
- This repository has no maintained specs or checks. Do not add them without a request.

## Verification

Evaluate affected flake outputs. For refactors, capture a baseline first and compare system and Home Manager derivations, generated files, and activation behavior as needed. Keep temporary verification artifacts outside the repository. Report exactly what was verified and any limitations. Never activate a system or push without an explicit request.

## Reusable skills

Reusable skill implementations belong in [ItsSkills](https://github.com/ItsEthanDev/its-skills). This repository owns the locked source input and discovery configuration, not those implementations.
