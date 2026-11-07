---
description: Retire old specifications while preserving behavior and useful requirements
---
Retire this project's old specifications so that code, behavioral tests, and concise current documentation carry the useful requirements without a parallel specification maintenance burden. Use the writing skill and follow the project's architecture and testing guidance.

## Assess and propose

Inspect the specifications, implementation, tests, documentation, and references to the specs. Find the established issue tracker through project guidance and repository configuration; ask the user if you cannot determine where it is.

Distinguish current requirements and constraints from obsolete plans, historical context, and unimplemented work. Surface conflicts between specifications and actual behavior rather than silently choosing one.

Present a brief assessment and proposed three-stage retirement plan. Explain only consequential changes and uncertainties. Stop for approval before editing files or the tracker.

## Implement after approval

1. **Prune.** Remove obsolete, redundant, and otherwise unnecessary specification content using the writing guidance. Preserve useful requirements, constraints, and rationale until they have an appropriate home.
2. **Encode.** Make relevant behavior clear through cohesive deep modules and descriptive tests of observable behavior. Refactor without changing external behavior or weakening meaningful test coverage. Keep current constraints and rationale that code or tests cannot express in project-owned documentation, understandable without reconstructing tracker history. Ask about ambiguous requirements or any necessary behavior change.
3. **Retire.** Archive useful historical material in the established tracker, using closed tickets for completed or historical work and open tickets for unimplemented requirements. Confirm that useful information has been preserved before removing the old specifications. Update documentation and agent pointers, and repair references to removed files.

Capture baseline behavior and check failures before refactoring. Run relevant checks afterward and verify that requirements were preserved at their new boundaries, not merely that the specs directory disappeared. Report what was removed, where useful material now lives, and any unresolved work or verification gaps.
