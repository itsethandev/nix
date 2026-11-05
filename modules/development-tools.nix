{
  inputs,
  lib,
  ...
}: {
  flake.modules.homeManager.development-tools = {pkgs, ...}: {
    home.packages = with pkgs;
      [cargo fd gh jq nodejs pnpm rustc tlrc unzip zip]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [codex gcc inputs.barnyard.packages.${pkgs.stdenv.hostPlatform.system}.barnyard javaPackages.compiler.temurin-bin.jre-25 pkg-config tuicr]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ripgrep zk];
    programs.direnv = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
