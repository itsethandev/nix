{lib, ...}: let
  package = {
    autoPatchelfHook,
    fetchurl,
    lib,
    makeWrapper,
    stdenvNoCC,
    xdg-utils,
  }: let
    releases = {
      x86_64-linux = {
        target = "linux-x64-baseline";
        sha256 = "1b4f1ee696f0e4169ca498089dea29e973274ac24535e6ebbc5cbd3a962a2952";
      };
      aarch64-linux = {
        target = "linux-arm64";
        sha256 = "4c7cc13c6b79f3fa81edc1edbb9dc797c99de0831e4ffc4e65fd2e62cb5b3d75";
      };
    };
    release = releases.${stdenvNoCC.hostPlatform.system};
  in
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "opencode-browse";
      version = "0.0.16";
      src = fetchurl {
        url = "https://anoma.ly/release/browse/files/${release.sha256}/opencode-browse-${release.target}-${finalAttrs.version}.tgz";
        inherit (release) sha256;
      };
      nativeBuildInputs = [autoPatchelfHook makeWrapper];
      # Bun's compiled executable contains its JavaScript payload after the ELF sections.
      dontStrip = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 bin/browse "$out/libexec/browse"
        install -Dm644 LICENSE "$out/share/doc/opencode-browse/LICENSE"
        makeWrapper "$out/libexec/browse" "$out/bin/browse" \
          --set OPENCODE_BROWSER_AUTO_UPDATE off \
          --prefix PATH : ${lib.makeBinPath [xdg-utils]}
        runHook postInstall
      '';
      meta = {
        description = "MCP server connecting AI agents to your Chromium browser";
        homepage = "https://github.com/anomalyco/browse";
        license = lib.licenses.mit;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        mainProgram = "browse";
        platforms = builtins.attrNames releases;
      };
    });
in {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.hasSuffix "-linux" system) {
      packages.agent-browser = pkgs.callPackage package {};
    };
  flake.modules.homeManager.agent-browser = {
    config,
    lib,
    pkgs,
    ...
  }: let
    browse = pkgs.callPackage package {};
  in {
    home.packages = [browse];
    programs.chromium.enable = lib.mkDefault true;
    programs.opencode.settings = lib.mkIf config.programs.opencode.enable {
      mcp.servers.agent-browser = {
        type = "local";
        command = lib.mkDefault [(lib.getExe browse) "mcp"];
      };
    };
  };
}
