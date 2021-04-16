{ pkgs, config, ... }:
let
  waylandEnablement = pkgs.writeShellScript "wayland-enablement" ''
    export CLUTTER_BACKEND=wayland
    export QT_QPA_PLATFORM=wayland-egl
    export ECORE_EVAS_ENGINE=wayland-egl
    export ELM_ENGINE=wayland_egl
    export SDL_VIDEODRIVER=wayland
    export _JAVA_AWT_WM_NONREPARENTING=1
    export NO_AT_BRIDGE=1
  '';

  swayRun = pkgs.writeShellScript "sway-run" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway
    source ${waylandEnablement}
    exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --debug $@
  '';
in
{
  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true; # so that gtk works properly
  #   extraPackages = with pkgs; [
  #     swaylock
  #     swayidle
  #     wl-clipboard
  #     mako # notification daemon
  #     alacritty # Alacritty is the default terminal in the config
  #     dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
  #   ];
  # };
  
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${swayRun}";
        user = "greeter";
      };
      initial_session = {
        command = "${swayRun}";
        user = "ben";
      };
    };
  };
}
