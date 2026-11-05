# Herdr OpenCode V2 integration: registration, not export shape

Research snapshot: **2026-11-05 UTC**. Primary-source investigation; no installation, activation, authenticated access, configuration changes, or commits. This note explains the evidence, not a configuration policy.

## Conclusion

**The directory wrapper is already Herdr's upstream solution, not an unsupported workaround.** Herdr v0.9.5 installs `herdr-opencode/tui.js`, re-exporting `../herdr-tui-session.js`, and registers `"./herdr-opencode"` in `cli.json`'s `plugins` array. Registering only `./herdr-tui-session.js` in `tui.jsonc` covers V1, not V2. Copying that single-file entry into `cli.json` is also insufficient: OpenCode 2.2.5 explicitly skips local file targets. [H2, H3, O2]

The installed shared plugin is integration version 13 and matches Herdr v0.9.5 byte-for-byte. The official `~/.config/opencode/herdr-opencode/tui.js` wrapper is also already present. The missing piece was its V2 registration, not an absent upstream implementation. The precise reason registration was missing remains unproven.

## Versions and official support

| Surface | Verified revision/date | Finding |
| --- | --- | --- |
| Latest published Herdr stable | **v0.9.5**, published **2026-10-14 16:07:28 UTC** | Includes V2 directory wrapper and `cli.json` registration. [H1–H3] |
| Herdr master | **`ee5bfb5041bb3e4a49d591c72308aae3c81ecdde`**, **2026-10-29** | Retains the same version-13 wrapper and registration scheme. [H4] |
| Initial released V2 support | **v0.9.1**, **2026-09-16** | PR #3757 merged **2026-09-11**, revision **`fb5525fc2234a246dfdfc9e0d7ed73c824cbd8a6`**; adds directory entrypoint and V2 `setup()`. [H5] |
| Latest listed OpenCode V2 release | **v2.2.5**, published **2026-10-30 23:17:23 UTC** | Still skips configured local files; directory resolution selects `tui`. [O1–O3] |

Herdr's current guide claims V1 **1.18.29+** and V2 support, explicitly tested with **beta 19242**, not specifically 2.2.5. It directs users to run `herdr integration install opencode` and restart the TUI; after updating, restart shared servers too. V2 session identity and lifecycle reporting belong to the **pane-local TUI**. The V2 server plugin's empty `setup()` is intentional; Mini/headless reporting is unsupported. [H4, H6]

## Why registration can be absent

The installer always writes the V2 wrapper, but deliberately defers `cli.json` creation when that file is absent and either V1 `tui.json` or state-directory `kv.json` exists. This avoids suppressing OpenCode's first-start preference migration. The documented manual step is to start `opencode2` once, then reinstall the integration. Without pending migration, the installer creates `cli.json`; it preserves other preferences/plugins. **Manual wrapper construction is not the normal supported setup.** [H2, H4]

Relevant upstream records distinguish separate problems:

- **Herdr #5333**, opened **2026-10-16**, remains **open**: v0.9.5/OpenCode 2.0.27 loses reporting when config management removes `cli.json` registration. It also identifies deferred registration without automatic retry. Proposed repair/retry PR **#5339** closed **2026-10-16 without merging**. This is a known registration-loss/repair gap, not proof that every fresh install fails. [H7]
- **OpenCode #46551**, opened **2026-09-01**, remains **open**: configured file paths are dropped. The **2026-10-28** response says directory-only configuration is intended V2 behavior and documentation was corrected; accepting files again or improving diagnostics remains a request. The TUI's 2.2.5 source independently confirms the file skip. [O2, O4]
- **Herdr #5375 / PR #5585**: non-default config-directory handling was fixed on master **2026-10-26**, revision **`2713feb56e9c9db33992db0a262c68f7426d46dd`**, but is explicitly **not in a published release**. Relevant if installation targeted a different directory; not established as this incident's cause. [H8]

## Recommendation

Treat the existing upstream directory layout and `cli.json` registration as the integration contract. Preserve both in any future declarative configuration; retaining only the shared v13 JavaScript file cannot satisfy it. Do not replace its compatible `{id, setup, tui}` export merely to address discovery.

For this installation, the simpler declarative registration can point to the existing upstream `herdr-opencode` directory instead of generating a duplicate wrapper. Herdr's status checker expects its own registration and currently reports `opencode: needs repair (v13)` despite successful reporting through the separately generated directory. This is a proposed cleanup, not a change made during this investigation.

Before changing anything, distinguish pending migration, overwritten registration, wrong config directory, and an older installer. Upstream already fixes the entrypoint-layout problem. The remaining Herdr improvement is explicit deferred-registration/repair status and a safe retry after migration, as tracked in #5333; OpenCode should make skipped explicit entries visible rather than silently ignoring them. Neither recommendation was implemented here.

## Verification and limits

- Read upstream tagged installer/assets, master docs/source, release APIs, and issue/PR records. The release list identifies 2.2.5 as the newest V2 entry; OpenCode's `/releases/latest` endpoint instead returned V1 1.19.5, so it was not used to identify latest V2.
- `cmp` confirmed installed `herdr-tui-session.js` equals upstream v0.9.5 and local `packages/tui/src/plugin/context.tsx` equals upstream v2.2.5. Local lines **333–341** skip files; `Host.resolve()` resolves a directory's `tui` entrypoint. [O2, O3]
- The research child did not access Ovis or private runtime logs. Earlier parent-session verification established a pane session ID and 22 turns from Ovis's `opencode-transcript` source after activating the generated directory wrapper. Parent inspection during research confirmed the official wrapper already exists and `herdr integration status` reports `needs repair (v13)`. No chat contents or credentials are retained in this note.
- No installer execution, activation, or Nix changes occurred during this investigation. The original installer version and reason for missing registration remain unverified; the deferred-migration path is an evidenced possibility, not an established history.

## Primary sources

- **H1:** [Herdr latest release API](https://api.github.com/repos/herdrdev/herdr/releases/latest), [v0.9.5 release](https://github.com/herdrdev/herdr/releases/tag/v0.9.5).
- **H2:** [v0.9.5 installer, `install_opencode`](https://github.com/herdrdev/herdr/blob/v0.9.5/src/integration/targets.rs#L463-L498), [registration/migration logic](https://github.com/herdrdev/herdr/blob/v0.9.5/src/integration/opencode_config.rs).
- **H3:** [v0.9.5 V2 wrapper](https://github.com/herdrdev/herdr/blob/v0.9.5/src/integration/assets/opencode/tui.js), [shared plugin](https://github.com/herdrdev/herdr/blob/v0.9.5/src/integration/assets/opencode/herdr-tui-session.js).
- **H4:** [Pinned master integration guide](https://github.com/herdrdev/herdr/blob/ee5bfb5041bb3e4a49d591c72308aae3c81ecdde/docs/next/website/src/content/docs/integrations.mdx#opencode), [pinned master config logic](https://github.com/herdrdev/herdr/blob/ee5bfb5041bb3e4a49d591c72308aae3c81ecdde/src/integration/opencode_config.rs), [master revision/date](https://api.github.com/repos/herdrdev/herdr/commits/ee5bfb5041bb3e4a49d591c72308aae3c81ecdde).
- **H5:** [V2 support PR #3757](https://github.com/herdrdev/herdr/pull/3757), [v0.9.1 release](https://github.com/herdrdev/herdr/releases/tag/v0.9.1), [v0.9.1 installer](https://github.com/herdrdev/herdr/blob/v0.9.1/src/integration/targets.rs), [version-13 PR #4357](https://github.com/herdrdev/herdr/pull/4357).
- **H6:** [#5214: intentional server no-op clarification](https://github.com/herdrdev/herdr/issues/5214#issuecomment-6136735677).
- **H7:** [Registration-loss issue #5333](https://github.com/herdrdev/herdr/issues/5333), [unmerged repair PR #5339](https://github.com/herdrdev/herdr/pull/5339).
- **H8:** [Config-directory issue #5375](https://github.com/herdrdev/herdr/issues/5375), [merged PR #5585](https://github.com/herdrdev/herdr/pull/5585).
- **O1:** [OpenCode release list API](https://api.github.com/repos/anomalyco/opencode/releases?per_page=12), [v2.2.5 release](https://github.com/anomalyco/opencode/releases/tag/v2.2.5).
- **O2:** [v2.2.5 TUI reconciliation, file-target skip](https://github.com/anomalyco/opencode/blob/v2.2.5/packages/tui/src/plugin/context.tsx#L332-L341).
- **O3:** [v2.2.5 entrypoint resolver](https://github.com/anomalyco/opencode/blob/v2.2.5/packages/plugin/src/host.ts#L25-L62), [official CLI plugin instructions](https://opencode.ai/v2/docs/cli/plugins/).
- **O4:** [Configured-file issue #46551](https://github.com/anomalyco/opencode/issues/46551), [2026-10-28 directory-only clarification](https://github.com/anomalyco/opencode/issues/46551#issuecomment-6476038967).
