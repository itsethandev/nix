{...}: let
  package = {
    bun,
    fetchFromGitHub,
    fetchurl,
    lib,
    makeWrapper,
    stdenvNoCC,
    writableTmpDirAsHomeHook,
  }: let
    version = "0.4.22";
    src = fetchFromGitHub {
      owner = "devswha";
      repo = "ovis";
      tag = "v${version}";
      hash = "sha256-paZjOPJqmf3JLBOEoSHrJQ5IbjqFYSHPaQnLBk/IplU=";
    };
    sidecars = {
      x86_64-linux = {
        platform = "linux-x64";
        sha256 = "44e589fa04c8f416bc691d6b39f8e9cb19b77965b490b351885808410d23649b";
      };
      aarch64-linux = {
        platform = "linux-arm64";
        sha256 = "d4ec12f5ffd874ce9368d6abb1738537dbf6e73e0cb593fffff8ffe30bc009dd";
      };
      aarch64-darwin = {
        platform = "darwin-universal";
        sha256 = "0ac8430e87e782b935dba90b3ed49f7383a082129f52b39c45d5916761d25a4c";
      };
    };
    sidecar = sidecars.${stdenvNoCC.hostPlatform.system};
    ptyHost = fetchurl {
      url = "https://github.com/devswha/ovis/releases/download/v${version}/ovis-pty-sidecar-${sidecar.platform}";
      inherit (sidecar) sha256;
    };
    fetchDependencies = {
      production,
      hash,
    }:
      stdenvNoCC.mkDerivation {
        pname =
          if production
          then "ovis-runtime-node-modules"
          else "ovis-node-modules";
        inherit version src;
        nativeBuildInputs = [bun writableTmpDirAsHomeHook];
        dontConfigure = true;
        dontFixup = true;
        buildPhase = ''
          runHook preBuild
          export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
          bun install --frozen-lockfile --ignore-scripts --no-progress --cpu="*" --os="*" ${lib.optionalString production "--production"}
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p "$out"
          cp -R node_modules "$out/"
          runHook postInstall
        '';
        outputHash = hash;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
      };
    buildDependencies = fetchDependencies {
      production = false;
      hash = "sha256-XP1J518gjN8zYuIPdmK4rR3N3G86l/u5+ezsKPdOtW0=";
    };
    runtimeDependencies = fetchDependencies {
      production = true;
      hash = "sha256-bvQTnGQ0gE2V1blt9X/KDXJxfN4gKycWVOXOl2Fasfo=";
    };
  in
    stdenvNoCC.mkDerivation {
      pname = "ovis";
      inherit version src;
      nativeBuildInputs = [bun makeWrapper writableTmpDirAsHomeHook];
      dontConfigure = true;
      # Keep the PTY host identical to its integrity record.
      dontStrip = true;
      postPatch = ''
        # Nix owns the version: retain Herdr's lifecycle without the update supervisor.
        substituteInPlace scripts/plugin.ts --replace-fail '"managed.ts"' '"index.ts"'
      '';
      buildPhase = ''
        runHook preBuild
        cp -R ${buildDependencies}/node_modules .
        chmod -R u+w node_modules
        bun node_modules/vite/bin/vite.js build
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        root="$out/lib/ovis"
        mkdir -p "$root/bin" "$out/bin"
        cp -R dist server shared scripts integrations public "$root/"
        cp -R ${runtimeDependencies}/node_modules "$root/"
        cp package.json herdr-plugin.toml LICENSE THIRD_PARTY_NOTICES.md "$root/"
        install -m755 ${ptyHost} "$root/bin/ovis-pty-sidecar"
        printf '{"version":"${version}","sha256":"%s"}\n' \
          "$(sha256sum "$root/bin/ovis-pty-sidecar" | cut -d ' ' -f1)" \
          > "$root/bin/ovis-pty-sidecar.json"
        # Herdr launches commands without an interactive shell's PATH.
        substituteInPlace "$root/herdr-plugin.toml" \
          --replace-fail '"sh", "scripts/with-bun.sh", "scripts/plugin.ts"' \
            '"${lib.getExe bun}", "scripts/plugin.ts"'
        makeWrapper ${lib.getExe bun} "$out/bin/ovis" \
          --add-flags "$root/scripts/plugin.ts" \
          --prefix PATH : ${lib.makeBinPath [bun]}
        runHook postInstall
      '';
      passthru = {inherit buildDependencies runtimeDependencies;};
      meta = {
        description = "Browser and phone client for Herdr";
        homepage = "https://github.com/devswha/ovis";
        license = lib.licenses.mit;
        mainProgram = "ovis";
        platforms = builtins.attrNames sidecars;
      };
    };
in {
  flake.overlays.ovis = final: _prev: {ovis = final.callPackage package {};};
  perSystem = {pkgs, ...}: {
    packages.ovis = pkgs.callPackage package {};
  };
  flake.modules.homeManager.ovis = {
    config,
    lib,
    pkgs,
    ...
  }: let
    ovis = pkgs.callPackage package {};
  in {
    home.packages = [ovis];
    xdg.configFile."herdr/plugins/config/devswha.ovis/env".text = ''
      HOST=127.0.0.1
      PORT=7317
      OVIS_STATE_DIR=${config.xdg.configHome}/ovis
    '';
    home.activation.ovisPlugin = lib.hm.dag.entryAfter ["linkGeneration"] ''
      run ${lib.getExe config.programs.herdr.package} plugin link ${ovis}/lib/ovis --enabled
    '';
    assertions = [
      {
        assertion = config.programs.herdr.enable && config.programs.herdr.package != null;
        message = "The Ovis module requires programs.herdr.enable and a Herdr package.";
      }
    ];
  };
}
