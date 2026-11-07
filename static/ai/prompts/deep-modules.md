---
description: Refactor the codebase into deep modules with approval before implementation
---
Refactor this codebase into cohesive deep modules: small public interfaces that hide substantial implementation complexity, improving code quality, testing, and maintenance while preserving behavior.

Read `src/modules/README.md` and follow its module conventions, especially its testing guidance. The dependency-cruiser bundle is already installed.

## 1. Explore and propose

Explore the codebase, its callers, and its tests. Capture existing behavior and baseline check failures. Design module boundaries around responsibilities rather than the current file layout.

Present a lightweight module breakdown: each module's responsibility and intended public interface, plus only the boundary tradeoffs needed to judge the design. Use your judgment for implementation details. Stop for user approval before editing.

## 2. Implement after approval

Refactor to the approved design. Internal interfaces and their callers may change; preserve externally consumed APIs, user-visible behavior, data formats, and side effects. Ask about ambiguous behavior or necessary breaking changes.

Redesign the tests around the modules' observable behavior rather than carrying the existing test structure forward. Rewrite, merge, delete, prune, or move tests as needed, preserving meaningful behavioral coverage at the appropriate boundaries. Follow the README's testing guidance: tests describe what a module does through its public interface, not how it works. Do not expose internals solely for testing.

Update the module catalog and run the project's relevant checks, including dependency-cruiser. Verify preserved behavior against the baseline and report remaining failures or verification gaps. Passing dependency rules alone is not the goal; assess whether the resulting modules hide complexity behind cohesive interfaces.
