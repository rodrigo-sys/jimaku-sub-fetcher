{
  description = "An mpv script to fetch Japanese subtitles using jimaku.cc";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forEachSystem (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = "jimaku-sub-fetcher";
          version = "1.0.0";
          
          src = ./.;

          dontBuild = true;

          propagatedUserEnvPkgs = [
            pkgs.curl
            pkgs.ffsubsync
            pkgs.python3Packages.guessit
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/jimaku-sub-fetcher
            cp -r * $out/share/jimaku-sub-fetcher
            rm -f $out/share/jimaku-sub-fetcher/flake.nix

            mkdir -p $out/bin
            cat <<- 'EOF' > $out/bin/jimaku-setup
            	#!/usr/bin/env bash
            	echo "Linking jimaku-sub-fetcher to your mpv config..."
            	mkdir -p $HOME/.config/mpv/scripts
            	ln -sf $HOME/.nix-profile/share/jimaku-sub-fetcher $HOME/.config/mpv/scripts/
            	echo "Done! jimaku-sub-fetcher is now active in mpv."
            	EOF
            
            chmod +x $out/bin/jimaku-setup

            runHook postInstall
          '';
        };
      });
    };
}
