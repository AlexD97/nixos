{ pkgs, ... }:
# pkgs.stdenv.mkDerivation rec {
#   pname = "snip";
#   version = "0.1.0";

#   src = pkgs.fetchgit {
#     #url = "https://pl-git.informatik.uni-kl.de/hinze/snip.git";
#     url = "git@pl-git.informatik.uni-kl.de:hinze/snip.git";
#     rev = "8e03331007a57fd9a621e3daf91610fae597416d";
#     sha256 = "sha256-MlqJOoMSRuYeG+jl8DFgcNnpEyeRgDCK2JlN9pOqBWA=";
#   };

#   buildInputs = [
#     pkgs.ghc
#   ];

#   buildPhase = ''
#     ghc --make -O2 Snip.lhs
#   '';

#   installPhase = ''
#     mkdir -p $out/bin
#     mv Snip $out/bin/snip
#     mv Snap $out/bin/snap
#   '';
# }

let
  haskellEnv = pkgs.haskellPackages.ghcWithPackages (ps: with ps; []);
in
pkgs.stdenv.mkDerivation {
  name = "Snip";

  src = ./.;

  buildInputs = [ pkgs.ghc ];

  buildPhase = ''
    ghc --make -O2 Snip.lhs
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp Snip $out/bin/
    ln -s $out/bin/Snip $out/bin/snip
    ln -s $out/bin/Snip $out/bin/snap
  '';

  meta = with pkgs.stdenv.lib; {
    description = "Snip";
  };
}

