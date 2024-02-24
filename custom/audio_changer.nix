{ pkgs, ... }:
let audio-changer = pkgs.stdenv.mkDerivation {
  name = "audio-changer";
  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
    ]))
  ];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./audio_changer.py} $out/bin/audio-changer";
};
