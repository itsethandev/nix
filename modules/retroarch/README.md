# RetroArch

`modules.homeManager.retroarch` installs RetroArch, starts its content browser in `~/Games/roms`, and sets the BIOS directory to `~/Games/bios`.

Home Manager creates `~/Games/saves` for in-game saves and `~/Games/states` for save states. RetroArch flushes supported in-game save data to disk every 10 seconds. It saves an automatic state on clean exit and loads it when reopening the game, where the core supports save states. Fast-forward is capped at 3× speed. Existing saves are not moved to the new directories.

Mesen is enabled for NES games. NES cartridge games need no BIOS; Famicom Disk System games require `~/Games/bios/disksys.rom`. Supply your own ROMs; they are not automatically scanned into playlists. Settings and cores can be configured through `programs.retroarch`.

On Linux, controller hotkeys use the bundled `udev` profiles. Hold Select/Back and press:

| Control position | Action |
| --- | --- |
| Left trigger | Rewind (hold) |
| Right trigger | Fast-forward (hold) |
| Left shoulder | Load state |
| Right shoulder | Save state |
| D-pad up | Toggle run-ahead |
| Start | Quit RetroArch |
| Top face button | Quick menu |
| Left face button | Toggle FPS |
| Bottom face button | Reset game |

Rewind is enabled; support depends on the core. Hotkeys follow button positions, not printed letters. Profiles without a Select/Back mapping keep their existing bindings. New or unrecognized controllers need a matching profile; the Steam Controller's native kernel-driver mapping still needs hardware verification.
