{
  inputs,
  lib,
  ...
}: {
  home = lib.genAttrs ["turing" "newton"] (host: {pkgs, ...}: {
    home.packages = with pkgs;
      [cargo fd gh jq nodejs pnpm rustc tlrc unzip zip]
      ++ lib.optionals (host == "turing") [codex gcc inputs.barnyard.packages.${pkgs.stdenv.hostPlatform.system}.barnyard javaPackages.compiler.temurin-bin.jre-25 pkg-config tuicr]
      ++ lib.optionals (host == "newton") [ripgrep zk];
    programs.direnv = lib.mkIf (host == "turing") {
      enable = true;
      enableFishIntegration = true;
    };
  });
}
