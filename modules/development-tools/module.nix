{
  flake.modules.homeManager.development-tools = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs;
      [fd gh jq tlrc unzip zip]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ripgrep zk];
  };
}
