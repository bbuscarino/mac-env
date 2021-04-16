{ lib, config, pkgs, modulesPath, ... }:
{
  imports = [
    ../profiles/network
    ../profiles/ssh
    ../users/serve
    ../users/root
    "${modulesPath}/installer/sd-card/sd-image-raspberrypi-installer.nix"
  ];
  nixpkgs.crossSystem = {
    config = "aarch64-linux";
  };
  boot = {
    loader.grub.enable = false;
    loader.raspberryPi.enable = true;
    loader.raspberryPi.version = 4;
    loader.raspberryPi.firmwareConfig = ''
      dtoverlay=disable-wifi
      dtoverlay=disable-bt
      dtparam=sd_poll_once
    '';
    loader.raspberryPi.uboot.enable = true;
    loader.raspberryPi.uboot.configurationLimit = 5;
    loader.generic-extlinux-compatible.enable = true;

    tmpOnTmpfs = false;
    cleanTmpDir = true;

    kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi1;

    # note, the annoying SD card messages when booting from not SD:
    # https://github.com/raspberrypi/linux/issues/3657

    initrd.availableKernelModules = [
      "pcie_brcmstb"
      "bcm_phy_lib"
      "broadcom"
      "mdio_bcm_unimac"
      "genet"
      "vc4"
      "bcm2835_dma"
      "i2c_bcm2835"
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "uas" # necessary for my UAS-enabled NVME-USB adapter
    ];
    kernelModules = config.boot.initrd.availableKernelModules;

    initrd.supportedFilesystems = [ "zfs" ];
    supportedFilesystems = [ "zfs" ];
  };
  hardware = {
    enableRedistributableFirmware = true;
  };
}
