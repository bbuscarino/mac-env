{ lib, config, pkgs, ... }: {

  imports = [
    ../profiles/graphical
    ../profiles/graphical/x
    ../profiles/graphical/xmonad
    ../profiles/security/yubikey
    ../profiles/development/android
    ../profiles/network
    ../profiles/core
    ../profiles/virt
    ../profiles/ssh
    ../users/ben
    ../users/root
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_5_10;
    # Turn on magical sysrq key for magic
    kernel.sysctl."kernel.sysrq" = 1;
    tmpOnTmpfs = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules =
      [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "r8169" ];
    extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  };
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/b92f846d-ef46-497c-96b8-50082e84e282";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/AE33-365C";
      fsType = "vfat";
    };
  services.logind.lidSwitchExternalPower = "ignore";
  services.fprintd.enable = true;
  services.fwupd.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
    xscreensaver.fprintAuth = true;
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/4eed79ae-0676-4f69-a27e-1f503993869b"; }];

  nix.maxJobs = lib.mkDefault 16;
  environment.systemPackages = with pkgs; [ mesa ];
  services.xserver.videoDrivers = [ "mesa" ];

  location.provider = "geoclue2";

  # All values except 'enable' are optional.
  services.redshift = {
    enable = true;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth = {
      enable = true;
      settings = {
        General = {
          ControllerMode = "bredr";
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };
  services.xserver.displayManager.sessionCommands =
    let
      customLayout = pkgs.writeText "xkb-layout" ''
        ! disable capslock
        clear lock
        clear lock
        clear mod3
        clear mod4
        keycode 66 = Hyper_L
        add mod3 = Hyper_L Hyper_R
        add mod4 = Super_L Super_R
      '';
    in
    ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap ${customLayout}
    '';

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings =
      let
        increment = 5;
      in
      [
        # Brightness
        { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -U ${toString increment}"; }
        { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -A ${toString increment}"; }
      ];
  };
}
