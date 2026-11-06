{
  flake.modules.homeManager.rust-toolchain = {pkgs, ...}: {
    home.packages = with pkgs; [cargo rustc];
  };
}
