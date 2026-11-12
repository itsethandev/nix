{
  flake.modules.homeManager.bun = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.bun];
    home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isLinux ["${config.home.homeDirectory}/.cache/.bun/bin"];
  };
}
