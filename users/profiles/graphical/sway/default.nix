{ pkgs, lib, config, ... }:
let
  lockCmd = "${pkgs.swaylock}/bin/swaylock --daemonize --show-failed-attempts --indicator-caps-lock --color '#282828'";
  idleCmd = ''${pkgs.swayidle}/bin/swayidle -w \
    timeout 300 "${lockCmd}" \
    timeout 600 "swaymsg 'output * dpms off'" \
    resume "swaymsg 'output * dpms on'" \
    before-sleep "${lockCmd}"'';
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    ${gsettings} set ${gnomeSchema} gtk-theme ${config.gtk.theme.name}
    ${gsettings} set ${gnomeSchema} icon-theme ${config.gtk.iconTheme.name}
  '';
  recursiveMergeAttrs = listOfAttrsets: lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) { } listOfAttrsets;
  # Status bar
  swayOutputIsActive = pkgs.writeShellScript "swayOutputIsActive.sh" ''
    ${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -rc '.[] | select(.name | contains("'$1'")) | select(.active == true)'
  '';
  a2dpIsActive = pkgs.writeShellScript "a2dpIsActive.sh" ''
    ${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/egrep -o "bluez_output[[:alnum:]._]+.a2dp-sink"
  '';
  bluezCard = pkgs.writeShellScript "bluezCard.sh" ''
    ${pkgs.pulseaudio}/bin/pactl list cards short | ${pkgs.gnugrep}/bin/egrep -o "bluez_card[[:alnum:]._]+"
  '';
  setProfile = pkgs.writeShellScript "setProfile.sh" ''
    ${pkgs.pulseaudio}/bin/pactl set-card-profile $(${bluezCard}) $1
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    config = {
      gaps = {
        smartBorders = "on";
      };
      fonts = [ "Iosevka" ];
      modifier = "Mod3";
      menu = "${pkgs.wofi}/bin/wofi";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      keybindings =
        let
          mods = [ "Mod1+Shift+Ctrl" "Mod3" ];
        in
        recursiveMergeAttrs
          (map
            (mod:
              let
                super = "${mod}+Mod4";
                cfg = config.wayland.windowManager.sway;
              in
              {
                "${mod}+F1" = "exec ${pkgs.symlinkJoin {
                  name = "chromium";
                  paths = [ pkgs.chromium ];
                  buildInputs = [ pkgs.makeWrapper ];
                  postBuild = ''
                      wrapProgram $out/bin/chromium \
                       --add-flags "--enable-features=UseOzonePlatform" \
                       --add-flags "--ozone-platform=wayland"
                  '';
                }}/bin/chromium";
                "${mod}+F2" = "exec ${pkgs.emacs}/bin/emacs";

                "${mod}+Return" = "exec ${cfg.config.terminal}";
                "${super}+q" = "kill";
                "${mod}+d" = "exec ${cfg.config.menu}";

                "${mod}+${cfg.config.left}" = "focus left";
                "${mod}+${cfg.config.down}" = "focus down";
                "${mod}+${cfg.config.up}" = "focus up";
                "${mod}+${cfg.config.right}" = "focus right";

                "${mod}+Left" = "focus left";
                "${mod}+Down" = "focus down";
                "${mod}+Up" = "focus up";
                "${mod}+Right" = "focus right";

                "${super}+${cfg.config.left}" = "move left";
                "${super}+${cfg.config.down}" = "move down";
                "${super}+${cfg.config.up}" = "move up";
                "${super}+${cfg.config.right}" = "move right";

                "${super}+Left" = "move left";
                "${super}+Down" = "move down";
                "${super}+Up" = "move up";
                "${super}+Right" = "move right";

                "${mod}+b" = "splith";
                "${mod}+v" = "splitv";
                "${mod}+f" = "fullscreen toggle";
                "${mod}+a" = "focus parent";

                "${mod}+s" = "layout stacking";
                "${mod}+w" = "layout tabbed";
                "${mod}+e" = "layout toggle split";

                "${super}+space" = "floating toggle";
                "${mod}+space" = "focus mode_toggle";

                "${mod}+1" = "workspace number 1";
                "${mod}+2" = "workspace number 2";
                "${mod}+3" = "workspace number 3";
                "${mod}+4" = "workspace number 4";
                "${mod}+5" = "workspace number 5";
                "${mod}+6" = "workspace number 6";
                "${mod}+7" = "workspace number 7";
                "${mod}+8" = "workspace number 8";
                "${mod}+9" = "workspace number 9";

                "${super}+1" =
                  "move container to workspace number 1";
                "${super}+2" =
                  "move container to workspace number 2";
                "${super}+3" =
                  "move container to workspace number 3";
                "${super}+4" =
                  "move container to workspace number 4";
                "${super}+5" =
                  "move container to workspace number 5";
                "${super}+6" =
                  "move container to workspace number 6";
                "${super}+7" =
                  "move container to workspace number 7";
                "${super}+8" =
                  "move container to workspace number 8";
                "${super}+9" =
                  "move container to workspace number 9";

                "${super}+minus" = "move scratchpad";
                "${mod}+minus" = "scratchpad show";

                "${super}+c" = "reload";
                "${super}+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

                "${mod}+r" = "mode resize";
                #"--release ${mod}+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save output ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
              })
            mods) // {
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 5%";
          "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 5%";
          #"--release Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save area ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
        };
      colors = {
        focused = {
          background = "#b16286";
          border = "#b16286";
          childBorder = "#b16286";
          indicator = "#b16286";
          text = "#ebdbb2";
        };
        focusedInactive = {
          background = "#689d6a";
          border = "#689d6a";
          childBorder = "#689d6a";
          indicator = "#689d6a";
          text = "#ebdbb2";
        };
        unfocused = {
          background = "#3c3836";
          border = "#3c3836";
          childBorder = "#3c3836";
          indicator = "#3c3836";
          text = "#ebdbb2";
        };
        urgent = {
          background = "#cc241d";
          border = "#cc241d";
          childBorder = "#cc241d";
          indicator = "#cc241d";
          text = "#ebdbb2";
        };
        placeholder = {
          background = "#000000";
          border = "#000000";
          childBorder = "#000000";
          indicator = "#000000";
          text = "#ebdbb2 ";
        };
      };
      bars = [
        {
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
          #fonts = [ "Iosevka 10" ];
          position = "top";
          extraConfig =
            "
            tray_output eDP-1
          ";
          colors = {
            background = "#3c3836";
            separator = "#666666";
            statusline = "#ebdbb2";
            activeWorkspace = {
              border = "#689d6a";
              background = "#689d6a";
              text = "#ebdbb2";
            };
            focusedWorkspace = {
              border = "#b16286";
              background = "#b16286";
              text = "#ebdbb2";
            };
            inactiveWorkspace = {
              border = "#3c3836";
              background = "#3c3836";
              text = "#ebdbb2";
            };
            urgentWorkspace = {
              border = "#cc241d";
              background = "#cc241d";
              text = "#ebdbb2";
            };
          };
        }
      ];
      input = {
        #   "type:keyboard" = {
        #     repeat_delay = "300";
        #     repeat_rate = "20";
        #     xkb_file = ''
        #       xkb_keycodes { include "evdev+aliases(qwerty)" };
        #       xkb_types    { include "default" };
        #       xkb_compat   { include "complete" };
        #       xkb_symbols  {
        #          include "pc+us(qwerty)+inet(evdev)+ctrl(nocaps)"
        #   // Less than/Greater than/Pipe key on Swedish keyboards becomes Compose
        #   //replace key <LSGT> { [ Multi_key ] };
        #   // Scroll Lock becomes Compose
        #   //replace key <SCLK> { [ Multi_key ] };
        #       };
        #       xkb_geometry { include "pc(pc105)" };
        #   //clear lock
        #   //clear lock
        #   //clear mod3
        #   //clear mod4
        #   //keycode 66 = Hyper_L
        #   //add mod3 = Hyper_L Hyper_R
        #   //add mod4 = Super_L Super_R
        # '';
        #   };
        "type:touchpad" = {
          dwt = "enabled";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      window = {
        titlebar = false;
        hideEdgeBorders = "smart";
        commands = [
          { command = "floating enable"; criteria = { app_id = "chromium"; }; }
          { command = "floating enable, resize set width 600px height 800px"; criteria = { title = "Save File"; }; }
          { command = "inhibit_idle visible, floating enable"; criteria = { title = "(is sharing your screen)|(Sharing Indicator)"; }; }
          { command = "move container to workspace 1"; criteria = { app_id = "^(?i)Chromium-browser$"; }; }
        ];
      };
      startup = [
        { command = "${idleCmd}"; }
        { command = "${importGsettings}"; always = true; }
        { command = "${pkgs.light}/bin/light -S 35%"; always = false; }
      ];
    };
    # extraConfig = ''
    #   seat seat0 xcursor_theme "capitaine-cursors"
    #   seat seat0 hide_cursor 60000
    # '';
  };
  # Status bar
  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "custom";
            command = "echo '{\"icon\":\"tux\", \"text\": \"'$(${pkgs.coreutils}/bin/uname -r)'\"}'";
            interval = "once";
            json = true;
          }
          {
            block = "custom";
            command = "[ $(cut -c 16- /nix/var/nix/gcroots/current-system/nixos-version) != $(curl -s -m 0.5 https://api.github.com/repos/NixOS/nixpkgs/git/refs/heads/nixos-unstable | jq '.object.sha' -r | cut -c 1-11) ] && echo '{\"icon\":\"upd\",\"state\":\"Info\", \"text\": \"Yes\"}' || echo '{\"icon\":\"noupd\",\"state\":\"Good\", \"text\": \"No\"}'";
            interval = 300;
            json = true;
          }
          { block = "uptime"; }
          { block = "cpu"; format = "{utilization} {frequency}"; }
          { block = "net"; device = "wlp3s0"; ssid = true; signal_strength = true; }
          { block = "backlight"; }
          { block = "temperature"; collapsed = false; }
          { block = "sound"; driver = "pulseaudio"; on_click = "${pkgs.pavucontrol}/bin/pavucontrol"; }
          { block = "battery"; driver = "upower"; }
          { block = "time"; on_click = "${pkgs.gsimplecal}/bin/gsimplecal"; }
        ];
        settings = {
          theme = {
            name = "gruvbox-dark";
            overrides = {
              idle_bg = "#3c3836";
            };
          };
          icons = {
            name = "awesome5";
            overrides = {
              tux = "  ";
              upd = "  ";
              noupd = "  ";
              volume_muted = "  ";
            };
          };
        };
        icons = "awesome5";
        theme = "gruvbox-dark";
      };
    };
  };


}
