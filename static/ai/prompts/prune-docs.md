---
description: Prune project documentation into concise, current, discoverable guidance
---
Prune this project's maintained documentation and agent guidance. Use the writing skill. Inspect the docs and relevant source, tests, and configuration to distinguish useful guidance from information readers can discover directly.

Rewrite, consolidate, relocate, or delete as needed. Remove planning residue, obsolete content, duplicate rules, file inventories, and implementation summaries that add no useful context. Preserve non-obvious constraints, safety boundaries, decisions, and rationale that code or tests cannot explain. Give each idea one authoritative home and link to it where needed.

Keep `README.md` lightweight: introduce the project, briefly explain what it does and how to run it, and index other documentation by role. Keep `AGENTS.md` lightweight: primarily direct agents to documentation based on when they need to read it. Overlap between these two navigation lists is intentional; the guidance they point to should remain in its owning document.

Describe the current system coherently rather than layering amendments onto old descriptions. Keep human-facing documentation understandable without agent instructions.

Perform straightforward cleanup without per-file approval. Ask when meaning or continued relevance is genuinely unclear. Leave `src/modules/README.md`, source code, tests, historical records, and reference material unchanged. Report opportunities to replace documentation with better code or tests separately rather than expanding into a refactor.

Verify that retained guidance matches the project, moved references and local links resolve, and documentation is reachable through the README and agent pointers. Summarize the cleanup and any unresolved questions briefly.
