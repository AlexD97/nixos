{ pkgs, ... }:
let snip = 
  pkgs.stdenv.mkDerivation rec {
    name = "Snip";

    src = ./Snip.lhs;

    buildInputs = [ pkgs.ghc ];

    unpackPhase = ''
      cp $src Snip.lhs
    '';

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
  };
in
{
  home.packages = [
    snip
  ];
}
