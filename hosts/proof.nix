{ lib, config, pkgs, ... }:
{
  imports = [
    ../profiles/graphical
    ../profiles/graphical/sway
    ../profiles/network
    ../profiles/ssh
    ../users/ben
    ../users/root
  ];
}
