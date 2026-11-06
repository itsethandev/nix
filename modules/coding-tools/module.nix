{
  flake.modules.homeManager.coding-tools = {pkgs, ...}: {
    home.packages = [pkgs.codex];
  };
}
