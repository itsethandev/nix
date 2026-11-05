{
  flake.modules.nixos.backups = {lib, ...}: {
    options.services.restic.backups = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        config = {
          timerConfig = {
            OnCalendar = lib.mkDefault "*-*-* 03:00:00";
            RandomizedDelaySec = lib.mkDefault "1h";
            Persistent = lib.mkDefault true;
          };
          pruneOpts = lib.mkDefault [
            "--keep-daily 14"
            "--keep-weekly 8"
            "--keep-monthly 12"
            "--keep-yearly 3"
          ];
          inhibitsSleep = lib.mkDefault true;
          initialize = lib.mkDefault true;
        };
      });
    };
  };
}
