{ pkgs, ... }:
{
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  sound.enable = true;

  hardware.pulseaudio.enable = true;


  environment = {
    systemPackages = with pkgs; [
      arandr
      gtk2
      gtk3
      pavucontrol
    ];

    sessionVariables = {
      # Fix java apps being broke in a tiling WM
      "_JAVA_AWT_WM_NONREPARENTING" = "1";
      # Theme settings
      QT_QPA_PLATFORMTHEME = "gtk2";
      XDG_DATA_DIRS = [ "/etc/xdg" ];
    };
    etc = {
      "xdg/gtk-2.0/gtkrc" = {
        text = ''
          gtk-theme-name = "Breeze-Dark"
          gtk-key-theme-name = "Breeze-Dark"
        '';
        mode = "444";
      };
      "xdg/gtk-3.0/settings.ini" = {
        text = ''
          [Settings]
          gtk-theme-name = Breeze-Dark
          gtk-key-theme-name = Breeze-Dark
        '';
        mode = "444";
      };
    };
  };

  services.gnome3.gnome-keyring.enable = true;


  # services.xserver = {
  #   enable = true;

  #   displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${pkgs.writeText "xkb-layout" ''
  #     ! disable capslock
  #     remove Lock = Caps_Lock
  #   ''}";

  #   desktopManager.wallpaper.mode = "fill";
  # };
}
