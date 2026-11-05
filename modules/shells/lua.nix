{
  perSystem = {pkgs, ...}: {
    devShells.lua = pkgs.mkShell {
      packages = with pkgs; [
        lua
        luarocks
        luaformatter
      ];
    };
  };
}
