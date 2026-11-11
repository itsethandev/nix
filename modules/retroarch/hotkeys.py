"""Add a position-based hotkey layout to RetroArch's Linux profiles."""

import json
from pathlib import Path
import re
import shutil
import sys


source, destination, bindings_file, controller_profiles = map(Path, sys.argv[1:])
bindings = json.loads(bindings_file.read_text())
shutil.copytree(source, destination)
# Add native profiles before deriving hotkeys from their normal controls.
(destination / "udev").chmod(0o755)
shutil.copytree(controller_profiles, destination / "udev", dirs_exist_ok=True)

for profile in (destination / "udev").glob("*.cfg"):
    lines = profile.read_text(encoding="utf-8-sig").splitlines()
    entries = {}
    for line in lines:
        match = re.match(r'\s*(\w+)\s*=\s*"([^"]*)"', line)
        if match:
            entries.setdefault(match[1], match[2])

    if not any(
        entries.get(f"input_select_{kind}", "nul") not in ("", "nul", "-1")
        for kind in ("btn", "axis")
    ):
        continue

    replacements = {}
    for action, control in bindings.items():
        for kind in ("btn", "axis"):
            key = f"input_{action}_{kind}"
            if control is None:
                replacements[key] = "nul"
                replacements[f"{key}_label"] = ""
                continue
            source_key = f"input_{control}_{kind}"
            replacements[key] = entries.get(source_key, "nul")
            replacements[f"{key}_label"] = entries.get(f"{source_key}_label", control)

    # Remove old bindings first: RetroArch uses the first occurrence of a key.
    lines = [
        line for line in lines
        if line.split("=", 1)[0].strip() not in replacements
    ]
    lines.extend(f'{key} = "{value}"' for key, value in replacements.items())
    profile.chmod(0o644)
    profile.write_text("\n".join(lines) + "\n")
