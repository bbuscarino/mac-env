{ pkgs, home, ... }: {
  xdg.configFile."dunst/dunstrc".source = ./dunstrc;
}
