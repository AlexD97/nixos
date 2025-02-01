{ config, ...}:
{
  xdg.configFile."eww/eww.yuck".source = ./eww.yuck;
  xdg.configFile."eww/eww.scss".source = ./eww.scss;
  xdg.configFile."eww/Control-Center".source = ./Control-Center;
  xdg.configFile."eww/Control-Center".recursive = true;
  #xdg.configFile."eww/Brightness".source = ./Brightness;
  #xdg.configFile."eww/Brightness".recursive = true;
}
