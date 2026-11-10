# RetroArch

`modules.homeManager.retroarch` installs RetroArch, starts its content browser in `~/Games/roms`, and sets the BIOS directory to `~/Games/bios`.

The menu uses Ozone with its built-in Gruvbox Dark palette, independent of the desktop's theme. No RetroArch patches are applied.

Home Manager creates `~/Games/saves` for in-game saves and `~/Games/states` for save states. RetroArch flushes supported in-game save data to disk every 10 seconds. It saves an automatic state on clean exit and loads it when reopening the game, where the core supports save states. Fast-forward is capped at 3× speed. Existing saves are not moved to the new directories.

Mesen is enabled for NES games. NES cartridge games need no BIOS; Famicom Disk System games require `~/Games/bios/disksys.rom`. Supply your own ROMs; they are not automatically scanned into playlists. Settings and cores can be configured through `programs.retroarch`.

Core-specific configuration lives in `cores/<core>.nix`. Mesen uses its core-provided aspect ratio, integer scaling, no bilinear smoothing, and no shader. These display settings apply only to Mesen; integer scaling can leave larger borders. Nix owns the Mesen core override file, so edit it here rather than using RetroArch's **Save Core Overrides** action. Automatic override loading must remain enabled.

Rewind and one-frame run-ahead are enabled for Mesen only. Run-ahead reduces internal input latency at additional CPU cost; its frame count may need adjustment per game. Use Select/Back + D-pad Up to toggle it if a game stutters or behaves incorrectly.

## Game library

Box-art thumbnails download on demand when browsing playlists with matching artwork. Playlists and downloaded artwork stay writable in RetroArch's default directories under `~/.config/retroarch`; Nix does not manage their contents.

### Add games or a new system

1. For a new system, enable its core through `programs.retroarch.cores` in Nix and rebuild using the [deployment instructions](../../README.md#deploy). Existing systems need no rebuild when adding games.
2. Put ROMs in a system-specific folder under `~/Games/roms`, such as `~/Games/roms/nes`. Supply any required BIOS files under `~/Games/bios`, using the filenames and subdirectories required by the core.
3. In RetroArch, select **Main Menu > Online Updater > Update Databases** on first setup or when refreshing game recognition.
4. Select **Import Content > Scan Directory**, open the system's ROM folder, and select **Scan This Directory**. Repeat this scan whenever you add games.
5. For each new system playlist, select **Settings > Playlists > Manage Playlists > [system playlist] > Default Core** and choose the preferred core. For NES, choose Mesen. This is a per-playlist choice, not a per-game task.

Database scans identify supported ROMs by content rather than filename; unrecognized ROMs need **Import Content > Manual Scan** or a manual playlist entry. For a manual scan, select the system name and preferred core. Artwork requires the standard system playlist name and a matching game title, such as `Super Mario Bros. (World)` in `Nintendo - Nintendo Entertainment System`.

### Keep the library updated

- **New games:** add the files and rescan their system folder. Existing playlist core assignments remain in place; no Nix rebuild is needed.
- **Moved or removed games:** remove stale entries from the playlist and rescan the new location as needed. Scanning is not a live folder sync.
- **Game databases:** use **Online Updater > Update Databases**, then rescan to retry recognition of previously unrecognized games.
- **Artwork:** matching box art downloads on demand while browsing. Check the playlist's system name and game titles if artwork is missing.
- **RetroArch, cores, and controller profiles:** update the repository's `nixpkgs` input through the normal Nix maintenance workflow, then rebuild. Do not use RetroArch's core or controller-profile updater for these Nix-managed packages. Core updates can invalidate save states; keep in-game saves backed up.

## Controller hotkeys

On Linux, controller hotkeys use the bundled `udev` profiles. Hold Select/Back and press:

| Control position | Action |
| --- | --- |
| Left trigger | Rewind (hold) |
| Right trigger | Fast-forward (hold) |
| Left shoulder | Load state |
| Right shoulder | Save state |
| D-pad up | Toggle run-ahead |
| Start | Close the game and return to the library |
| Top face button | Quick menu |
| Left face button | Toggle FPS |
| Bottom face button | Reset game |

Hotkeys follow button positions, not printed letters. Profiles without a Select/Back mapping keep their existing bindings. New or unrecognized controllers need a matching profile; the Steam Controller's native kernel-driver mapping still needs hardware verification.
