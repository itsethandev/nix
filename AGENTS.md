# Agent instructions

Read [STANDARDS.md](STANDARDS.md) before structuring, maintaining, or editing the project. Read [README.md](README.md) for repository structure and deployment commands.

## Configuration changes

- Read relevant Nix before editing.
- Keep the existing input pins unless an update is requested.
- This repository has no maintained specs. Do not add them without a request.

## Verification

For refactors, capture a baseline first and compare system and Home Manager derivations, generated files, and activation behavior as needed. Keep temporary verification artifacts outside the repository. Never activate a system or push without an explicit request.

## Reusable skills

Reusable skill implementations belong in [ItsSkills](https://github.com/ItsEthanDev/its-skills). This repository owns the locked source input and discovery configuration, not those implementations.
