{ lib, config, pkgs, hardware, ... }: {

  imports = with hardware; [
    ../users/ben
    ../profiles/graphical
    ../profiles/graphical/xmonad
    # Hardware
    lenovo-thinkpad-t14s
    common-cpu-amd
    common-pc
    common-pc-ssd
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules =
      [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-amd" ];
    supportedFilesystems = [ ];
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

  swapDevices =
    [{ device = "/dev/disk/by-uuid/4eed79ae-0676-4f69-a27e-1f503993869b"; }];

  nix.maxJobs = lib.mkDefault 16;
  environment.systemPackages = with pkgs; [ mesa ];
  services.xserver.videoDrivers = [ "mesa" ];

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.nitrogen}/bin/nitrogen --set-auto=${../assets/wallpaper.png} --head=0
  '';

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      # Capslock
      { keys = [ 58 ]; events = [ "key" ]; attributes = [ "key(29)" "key(42)" "key(56)" "rel(29)" "rel(42)" "rel(56)" "noexec" ]; }
      # Brightnessaqw
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };
}