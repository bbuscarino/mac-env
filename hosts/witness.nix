{ lib, config, pkgs, ... }:
{
  imports = [
    ../profiles/graphical
    ../profiles/graphical/games
    ../profiles/graphical/x
    ../profiles/graphical/xmonad
    ../profiles/security/yubikey
    ../profiles/development/android
    ../profiles/network
    ../profiles/virt
    ../profiles/ssh
    #../profiles/hydra
    ../profiles/core
    ../users/ben
    ../users/root
  ];

  networking.hostName = "witness";
  xdg.portal.enable = true;
  sound.mediaKeys.enable = true;

  nix.buildMachines = [
    {
      hostName = config.networking.hostName;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
  services.flatpak.enable = true;
  # nix.distributedBuilds = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_5_11;
    # Turn on magical sysrq key for magic
    kernel.sysctl."kernel.sysrq" = 1;
    tmpOnTmpfs = true;

    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/nvme0n1";
      };
    };
    initrd.availableKernelModules =
      [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "exfat" ];
    kernelModules = [ "kvm-amd" "nvidia" "coretemp" "k10temp" ];
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cc55a8e5-9b2f-4562-bdf8-5efdaa1a7f68";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2bbdeb41-6a64-4341-a04f-a3f01cbe812a"; }];


  # fileSystems."/mnt/windows" = {
  #   device = "/dev/disk/by-uuid/4E3604C83604B34F";
  #   fsType = "ntfs";
  #   options = [ "rw" "uid=${toString config.users.users.ben.uid}" ];
  # };

  nix.maxJobs = lib.mkDefault 16;
  hardware.nvidia.prime.offload.enable = false;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --left-of DVI-D-0
    ${pkgs.xlibs.xrandr}/bin/xrandr --output DVI-D-0 --primary
    ${pkgs.xlibs.xrandr}/bin/xrandr --output DP-0 --right-of DVI-D-0
  '';
}
