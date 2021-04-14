{ lib, config, pkgs, mobile, ... }:
{
  imports = [
    ../profiles/graphical
    ../profiles/graphical/sway
    ../profiles/network
    ../profiles/ssh
    ../users/ben
    ../users/root
    mobile.pine64-pinephone
  ];
  nixpkgs.system = "aarch64-linux";
}
