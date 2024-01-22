{ pkgs, ... }:
{
  xdg.configFile."sioyek/keys_user.config".source = ./sioyek_keys_user.config;
  xdg.configFile."sioyek/prefs_user.config".source = ./sioyek_prefs_user.config;
  xdg.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
  xdg.configFile."alacritty/themes/AtomOneLight.conf".source = ./alacrittyAtomOneLight.conf;
  xdg.configFile."alacritty/themes/AtomOneDark.conf".source = ./alacrittyAtomOneDark.conf;
}
