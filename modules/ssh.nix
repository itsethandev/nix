{
  nixos.turing = {lib, ...}: {
    services.openssh = {
      enable = lib.mkDefault true;
      openFirewall = false;
      settings.KbdInteractiveAuthentication = lib.mkDefault false;
      settings.PasswordAuthentication = lib.mkDefault false;
    };
    users.users.ethan.openssh.authorizedKeys.keyFiles = let
      directory = ../static/ssh;
      entries = builtins.readDir directory;
    in
      map (file: "${directory}/${file}") (builtins.filter
        (file: entries.${file} == "regular" && lib.hasSuffix ".pub" file)
        (builtins.attrNames entries));
  };
}
