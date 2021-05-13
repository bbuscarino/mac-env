{ lib, config, pkgs, modulesPath, ... }:
{
  imports = [
    #../profiles/network
    ../profiles/ssh/server
    ../profiles/core
    ../profiles/installer/raspberry-pi.nix
    ../users/ben/server.nix
    ../users/root
    
  ];
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;

    # force cross-compilation here
    #nixpkgs.system = "x86_64-linux"; # should be set in flake.nix anyway
    nixpkgs.crossSystem = lib.systems.examples.raspberryPi;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    security.polkit.enable = false;
    services.udisks2.enable = false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    nix.package = lib.mkForce pkgs.nix;

    boot.initrd.availableKernelModules = lib.mkForce [ 
      "mmc_block"
      "usbhid"
      "hid_generic"
      "hid_microsoft"
     ];

    # rpizero stuffs
    # boot.otg = {
    #   enable = true;
    #   module = "ether";
    # };

    # fileSystems = {
    #   "/boot" = {
    #     device = "/dev/disk/by-partlabel/FIRMWARE";
    #     fsType = "vfat";
    #     options = [ "nofail" ];
    #   };
    #   "/" = {
    #     device = "/dev/disk/by-partlabel/NIXOS";
    #     fsType = "ext4";
    #   };
    # };

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi0;

      loader.grub.enable = false;
      loader.raspberryPi = {
        enable = true;
        uboot.enable = true;
        version = 0;
      };
    };

    networking = {
      hostName = "rpi";
      #firewall.enable = true;
      #firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.enable = lib.mkForce false;
      wireless.iwd.enable = true;
    };
}
