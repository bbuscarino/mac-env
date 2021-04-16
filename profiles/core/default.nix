{ config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  environment = {
    pathsToLink = [ "/share/zsh" ];
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      git
      gotop
      gptfdisk
      iputils
      jq
      manix
      moreutils
      nix-index
      nmap
      ripgrep
      skim
      tealdeer
      usbutils
      utillinux
      whois
    ];



    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # git
        g = "git";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        srch = "ns nixos";
        orch = "ns override";
        nrb = ifSudo "sudo nixos-rebuild --flake $HOME/env";
        mn = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
        '';

        # fix nixos-option
        nixos-option = "nixos-option -I nixpkgs=${toString ../../compat}";

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";

        # top
        top = "gotop";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";

      };
  };

  time.timeZone = "America/New_York";

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      font-awesome-ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      siji
      noto-fonts
      powerline-fonts
      dejavu_fonts
      nerdfonts
      hack-font
    ];
    fontconfig.defaultFonts = {

      monospace = [ "DejaVu Sans Mono for Powerline" ];

      sansSerif = [ "DejaVu Sans" ];

    };
  };

  nix = {

    autoOptimiseStore = true;

    gc.automatic = true;

    optimise.automatic = true;

    useSandbox = true;


    allowedUsers = [ "@wheel" ];

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      fallback = true
      min-free = 536870912
      builders-use-substitutes = true
      secret-key-files = ${config.sops.secrets.cache_private_key.path}
    '';

  };

  programs.bash = {

    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  security = {
    protectKernelImage = true;
  };

  services.earlyoom.enable = true;

  users.mutableUsers = false;
}
