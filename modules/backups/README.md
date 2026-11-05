# Backups

`modules.nixos.backups` supplies defaults for each job in `services.restic.backups`. Callers supply the repository, paths, and credential files.

Jobs run at 03:00 with up to one hour of random delay, catch up after missed runs, inhibit sleep, and initialize missing repositories. Retention keeps 14 daily, 8 weekly, 12 monthly, and 3 yearly snapshots. These defaults are overridable.
