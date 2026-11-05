{
  perSystem = {pkgs, ...}: let
    mdts = pkgs.buildNpmPackage {
      pname = "mdts";
      version = "0.20.6";
      src = ./mdts;
      npmDepsHash = "sha256-upjCEWTbFEDXdqnlcpQg7HSONvvWobyC1I5VHljsTrk=";
      dontNpmBuild = true;
    };
    python = pkgs.python3.withPackages (pythonPackages:
      with pythonPackages; [
        beautifulsoup4
        python-dateutil
        pyyaml
        requests
        strictyaml
      ]);
  in {
    devShells.pi = pkgs.mkShell {
      packages =
        [
          pkgs.alejandra
          pkgs.bun
          pkgs.coreutils
          pkgs.curl
          pkgs.dnsutils
          pkgs.fd
          pkgs.ffmpeg
          pkgs.file
          pkgs.findutils
          pkgs.gawk
          pkgs.gh
          pkgs.git
          pkgs.htmlq
          pkgs.hunk
          pkgs.imagemagick
          pkgs.jq
          pkgs.lychee
          mdts
          pkgs.nodejs
          pkgs.openssl
          pkgs.pandoc
          pkgs.pi-coding-agent
          pkgs.poppler-utils
          python
          pkgs.ripgrep
          pkgs.sqlite
          pkgs.tectonic
          pkgs.unzip
          pkgs.xh
          pkgs.yq-go
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.wl-clipboard];

      shellHook = ''
        if [[ $- == *i* ]]; then
          exec pi
        fi
      '';
    };
  };
}
