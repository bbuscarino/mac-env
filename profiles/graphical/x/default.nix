{ pkgs, ... }: {
  services.xserver = {
    enable = true;

    displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${pkgs.writeText "xkb-layout" ''
      ! disable capslock
      remove Lock = Caps_Lock
    ''}";

    desktopManager.wallpaper.mode = "fill";

    displayManager.lightdm.greeters.gtk = {
      enable = true;
      theme = {
        package = pkgs.breeze-gtk;
        name = "Breeze-Dark";
      };
      iconTheme = {
        package = pkgs.breeze-icons;
        name = "breeze-dark";
      };
      indicators = [ "~host" "~spacer" "~clock" "~spacer" "~session" ];
    };
  };
}
