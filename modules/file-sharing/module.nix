{
  flake.modules.nixos.file-sharing = {
    config,
    lib,
    ...
  }: let
    primaryUser = config.fileSharing.user;
    directory = config.services.samba.settings.public.path;
  in {
    options.fileSharing.user = lib.mkOption {
      type = lib.types.str;
      description = "Local user who owns and authenticates to the public share.";
    };
    config = {
      services.samba = {
        enable = true;
        openFirewall = false;
        nmbd.enable = false;
        winbindd.enable = false;

        settings.public = {
          path = lib.mkDefault "${config.users.users.${primaryUser}.home}/Public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = [primaryUser];
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };

      systemd.tmpfiles.rules = [
        "d ${directory} 0750 ${primaryUser} users -"
      ];
    };
  };
}
