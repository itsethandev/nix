{
  perSystem = {pkgs, ...}: {
    devShells.rust = pkgs.mkShell {
      packages = with pkgs; [
        gcc
        rustup
      ];
    };
  };
}
