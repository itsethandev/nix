# Omarchy features worth borrowing

Research date: 2026-11-08. Scope: recommendations for the declared `turing` desktop, with `newton` considered where useful. These are candidates, not accepted changes or an implementation specification. No system configuration was changed or activated.

## Recommendation

Borrow complete workflows rather than replace the desktop stack. Start with region OCR, quick video capture, and searchable shortcuts/system actions. Presentation mode is a close fourth because it can reuse the existing OBS projector integration.

The comparison uses repository declarations and locked upstream source, not an inspection of running applications or writable settings. Runtime overrides may change what is already available.

## What current Omarchy offers

The announced release is [Omarchy 4.5][release]. Its current desktop combines Hyprland with an integrated Quickshell shell; older descriptions centered on Walker and Waybar are not the right baseline. Release source is cited at `v4.5.0` where practical; live documentation can move ahead of that tag. Sources: [release announcement][release], [release page][release-tag], [built-in shell catalog][shell-catalog].

- **Desktop navigation:** tiling, scrolling, and floating workspace layouts; window groups, scratchpad, dock, and a persistent drop-down agent console. [Navigation][navigation]
- **Capture and sharing:** Omasnap screenshots with annotation and scrolling capture; region OCR and QR extraction; region/window/monitor video with audio and optional webcam; transcoding and LocalSend sharing. [Capture manual][capture]
- **Everyday controls:** unified copy/paste and clipboard history; an audio panel; actionable notification history; DND, stay-awake, locking, and night light. [Clipboard][clipboard], [bar][bar], [notifications][notices], [idle controls][idle]
- **Appearance and extension:** coordinated app/shell themes, customizable bars, and separately installed community shell plugins. Plugins are not a sandbox and are not automatically compatible with Noctalia. [Themes][themes], [plugin manual][plugins]
- **Development and compatibility:** terminal/editor choices, language environments, Docker, coding agents, Steam and other gaming options, browser web apps, and an optional Windows VM. The VM is documented for work apps, not GPU-heavy gaming. [Official overview][home], [web apps][webapps]
- **Diagnosis and recovery:** a crash notification can open a selected agent; system snapshots and subsystem restart tools support recovery. Root snapshots do not restore personal files in `/home`. [Crash watcher][crash-watch], [snapshots][snapshots]

Most of the value is in joining selection, action, visible status, and a useful result into one workflow, rather than in installing a particular package.

## What the configuration already covers

| Capability | Repository evidence | Implication |
| --- | --- | --- |
| Hyprland, Noctalia, PipeWire, UWSM | [`session.nix`](../../modules/desktop/session.nix), [`audio.nix`](../../modules/desktop/audio.nix) | A different compositor or shell is not needed to borrow desktop workflows. |
| App launcher, clipboard panel, screenshot shortcuts, mic mute, media keys | [`shell.nix`](../../modules/desktop/shell.nix) | Do not add another launcher, clipboard daemon, or screenshot stack without a specific missing behavior. |
| Screenshot annotation, calculator/emoji launcher providers, notification history, privacy indicators | [Pinned Noctalia defaults][noctalia-defaults] | These capabilities already exist upstream even though the repository does not explicitly configure every one. |
| Dictation, cursor zoom, color picker | [`dictation`](../../modules/dictation/README.md), [`cursor-zoom`](../../modules/cursor-zoom/README.md), [`color-picker`](../../modules/color-picker/README.md) | Omarchy equivalents would mostly duplicate existing capabilities. |
| OBS, virtual camera, projector workspace, phone camera | [`recording`](../../modules/recording/module.nix), [`phone-camera`](../../modules/phone-camera/README.md) | Quick capture and presentation coordination would extend an existing workflow, not replace OBS. |
| Steam, development tools, terminal utilities, coding agents, Herdr | [`turing` selections](../../hosts/turing/configuration.nix), [`newton` selections](../../hosts/newton/configuration.nix) | Most bundled apps are not meaningful additions. |
| LocalSend, Tailscale-restricted Samba, Restic | [`turing` configuration](../../hosts/turing/configuration.nix) | File transfer and scheduled backups already exist; restore usability is a separate opportunity. |
| Declarative colors, fonts, icons, generated wallpaper | [`appearance.nix`](../../modules/desktop/appearance.nix) | Keep Stylix as the managed theme source rather than introduce competing runtime writers. |

Noctalia's locked defaults expose DND and caffeine controls, while night light and DDC monitor brightness are disabled by default. The repository binds brightness actions but does not enable DDC. Its two declared displays are external outputs. These are configuration opportunities rather than reasons to install another shell. Sources: [Noctalia defaults][noctalia-defaults], [Noctalia IPC][noctalia-ipc], [`displays.nix`](../../hosts/turing/displays.nix), [`shell.nix`](../../modules/desktop/shell.nix).

## Candidate workflows

Effort is a relative estimate of integration and ongoing maintenance, not a measured implementation time.

| Priority | Candidate | Useful behavior on this system | Integration and cost |
| --- | --- | --- | --- |
| 1 | Region OCR to clipboard | Select text in an image, video, remote desktop, or unselectable error dialog and paste it into an editor or agent. | Low: a local capture/selection command and Tesseract. Avoid retaining captures by default. |
| 2 | Quick region/window video capture | Record a short reproduction without opening an OBS scene, then open the resulting file or folder. | Medium: reuse `recording` ownership; choose a recorder after checking GPU/Wayland support. Show recording state and provide a reliable stop action. |
| 3 | Searchable shortcuts and system actions | Find infrequent actions such as dictation cancel, projector toggle, clipboard clear, audio controls, and capture without remembering every chord. | Low–medium: extend Noctalia's existing launcher with desktop actions and a shortcut guide. Derive the guide from configured bindings where practical; avoid a second manually synchronized inventory. |
| 4 | Reversible presentation mode | Coordinate DND, idle inhibition, and the existing projector workspace for calls and demos. | Low–medium: reuse Noctalia IPC and OBS integration. Restore the prior DND/inhibitor state instead of blindly toggling both on exit. |
| 5 | Opt-in crash diagnosis | A failed app offers a bounded diagnostic report and an explicit action to open a coding agent. | Medium: distinguish coredumps from other failures. Start with local metadata/logs, not automatic upload of core memory, environment variables, or unrelated logs. |
| 6 | External monitor brightness and night light | Adjust the two desktop monitors from the same controls already bound to brightness keys; optionally schedule warmer evening colors. | Low configuration cost; verify monitor support, permissions, and compositor protocols. Use Noctalia's existing DDC/night-light support rather than add duplicate daemons. Keep night-light preferences optional. |
| 7 | Backup status and restore browser | See the last successful backup and recover a file without reconstructing Restic commands. | Medium: reuse the existing R2 repository and credential boundary. Do not start a second scheduler or copy secrets into user configuration. |
| 8 | Declarative web-app launchers | Give frequently used sites launcher entries and predictable window rules. | Low for normal browser launchers; higher for isolated app windows if another browser is needed. Keep Zen unless app-window behavior justifies the extra dependency. |

### Evidence and differences for the shortlist

1. **OCR is built in:** Omarchy selects a region, runs Tesseract, and copies the extracted text. This is a new workflow here, not a reason to replace Noctalia screenshots. [Release-tag OCR manual][ocr]
2. **Quick recording is built in:** the capture menu selects region/window/monitor and audio; a bar indicator and repeat shortcut stop recording. Borrow the complete interaction, not necessarily its recorder implementation. [Capture manual][capture], [recorder source][recorder]
3. **Action discovery is built in:** Learn > Keybindings opens an interactive guide assembled from Hyprland bindings, with additional handling for Lua. A separate searchable system menu includes capture, appearance, setup, and system actions. Nix metadata can avoid copying Omarchy's source-scanning machinery. [Keybinding guide source][keybindings], [menu definition][menu]
4. **Combined presentation mode is a local proposal:** Omarchy documents separate DND and stay-awake controls. Its DND has exceptions, so it is not an absolute screen-sharing privacy guarantee. [Idle controls][idle], [notification behavior][notices]
5. **Crash offers are built in:** a watcher monitors coredump journal events and offers diagnosis for the selected agent, with repeat suppression and per-program muting. This is not proof of autonomous repair or of every application failure being captured. [Crash watcher][crash-watch], [agent launcher][crash-agent]
6. **Night light is available, not scheduled by default:** Omarchy documents a manual toggle; scheduling requires additional configuration. DDC brightness is recommended here because of the existing external monitors and Noctalia support, not as a verified Omarchy-specific feature. [Idle controls][idle], [Noctalia defaults][noctalia-defaults]
7. **Personal backup browsing is not a verified built-in:** Omarchy's root snapshot workflow excludes `/home`. Its homepage advertises a community "Time Machine" plugin with scheduled Restic backups and a snapshot browser; that listing is evidence of an optional idea, not a tested integration or a reason to replace this repository's scheduler. [Snapshots][snapshots], [official homepage plugin showcase][home]
8. **Web apps are built in:** Omarchy creates launchers and frameless browser windows, with an optional Microsoft browser-app bundle. These are web apps, not native Linux Office applications. [Web-app manual][webapps]

The locked nixpkgs exposes `tesseract`, `grim`, `slurp`, `wf-recorder`, `wl-screenrec`, `gpu-screen-recorder`, `wl-mirror`, `ddcutil`, and `restic-browser` on `x86_64-linux`. This was checked by attribute evaluation, not by building or exercising the packages. Availability does not settle which recorder or restore interface is the best fit. Source: [`flake.lock`](../../flake.lock), nixpkgs revision `1d060086d60cb76a40cf37109f979d88a5bd6396`.

## Boundaries

- Prefer existing feature ownership: capture belongs with `recording`; shell actions with `desktop`; backup status/restore with `backups`. A self-contained OCR feature is reasonable if independently useful. Follow [`STANDARDS.md`](../../STANDARDS.md), not Omarchy's installation layout.
- Omarchy shell plugins are not assumed compatible with Noctalia. Borrow their behavior; separately assess code reuse and packaging.
- Do not copy Arch installation/update scripts, replace Nix generations with Omarchy's update model, or add a second theme authority.
- A Windows VM, retro emulators, and hardware-specific plugins are conditional candidates only when there is an actual application, game, or device requirement.
- Most recommendations target `turing`. The ideas of action discovery and web-app launchers can also apply to `newton`, but the Linux capture, shell IPC, and DDC implementation cannot be assumed portable.

## Verification limits

The comparison checked local feature selections, the locked Noctalia source, Omarchy's official manual and release source, and package attribute availability. It did not install or run Omarchy, build candidate packages, access backup contents, test monitor control, or activate a Nix generation. Cost and usefulness rankings are judgments, not upstream claims.

[home]: https://omarchy.org/
[release]: https://omarchy.org/news/2026/11/omarchy-4-5/
[release-tag]: https://github.com/omacom/omarchy/releases/tag/v4.5.0
[shell-catalog]: https://github.com/omacom/omarchy/blob/v4.5.0/shell/plugins/README.md
[navigation]: https://omarchy.org/manual/navigation/
[capture]: https://omarchy.org/manual/screenshots-recording/
[clipboard]: https://omarchy.org/manual/unified-clipboard-history/
[bar]: https://omarchy.org/manual/the-top-bar/
[notices]: https://omarchy.org/manual/notices/
[idle]: https://github.com/omacom/omarchy/blob/v4.5.0/manual/13-toggles-idle-screensaver.md
[themes]: https://omarchy.org/manual/themes/
[plugins]: https://github.com/omacom/omarchy/blob/v4.5.0/manual/32-shell-plugins.md
[webapps]: https://omarchy.org/manual/web-apps/
[ocr]: https://github.com/omacom/omarchy/blob/v4.5.0/manual/11-text-extraction-dictation.md
[recorder]: https://github.com/omacom/omarchy/blob/v4.5.0/bin/omarchy-capture-screenrecording
[keybindings]: https://github.com/omacom/omarchy/blob/v4.5.0/bin/omarchy-menu-keybindings
[menu]: https://github.com/omacom/omarchy/blob/v4.5.0/default/omarchy/omarchy-menu.jsonc
[crash-watch]: https://github.com/omacom/omarchy/blob/v4.5.0/bin/omarchy-crash-watch
[crash-agent]: https://github.com/omacom/omarchy/blob/v4.5.0/bin/omarchy-agent-crash
[snapshots]: https://github.com/omacom/omarchy/blob/v4.5.0/manual/47-system-snapshots.md
[noctalia-defaults]: https://github.com/noctalia-dev/noctalia/blob/43bfc457421db865961d18526967df7c85465f56/example.toml
[noctalia-ipc]: https://github.com/noctalia-dev/noctalia/blob/43bfc457421db865961d18526967df7c85465f56/src/cli/schema_msg.h
