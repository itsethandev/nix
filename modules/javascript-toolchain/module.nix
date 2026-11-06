{
  flake.modules.homeManager.javascript-toolchain = {pkgs, ...}: {
    home.packages = with pkgs; [nodejs pnpm];
  };
}
