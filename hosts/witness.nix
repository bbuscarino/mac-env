{ lib, config, pkgs, hardware, suites, ... }:
{
  imports = with hardware; [
    ../profiles/graphical
    ../profiles/graphical/games
    ../profiles/graphical/xmonad
    ../profiles/security/yubikey
    ../profiles/development/android
    ../profiles/network
    ../profiles/virt
    ../profiles/ssh
    ../profiles/hydra
    ../users/ben
    ../users/root
    # Hardware
    common-cpu-amd
    common-gpu-nvidia
    common-pc
    common-pc-ssd
  ] ++ suites.base;

  sound.mediaKeys.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_5_10;
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
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xlibs.xrandr}/bin/xrandr --output HDMI-0 --left-of DVI-D-0
    ${pkgs.xlibs.xrandr}/bin/xrandr --output DVI-D-0 --primary
    ${pkgs.xlibs.xrandr}/bin/xrandr --output DP-0 --right-of DVI-D-0
  '';
}
