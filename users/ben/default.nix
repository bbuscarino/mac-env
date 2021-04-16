{ config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  imports = [
    # User specific stuff
    #./restic
    ./syncthing
  ];

  sops.secrets.gitconfig_home = {
    mode = "0777";
    owner = config.users.users.ben.name;
    path = "${config.users.users.ben.home}/.gitconfig";
  };

  home-manager.users.ben = { home, ... }:
    {
      imports = [
        ../profiles/alacritty
        ../profiles/develop
        ../profiles/develop/nix
        ../profiles/develop/purescript
        ../profiles/develop/python
        ../profiles/develop/flutter
        ../profiles/direnv
        ../profiles/emacs
        ../profiles/git
        ../profiles/gpg
        ../profiles/graphical
        ../profiles/graphical/xmonad
        ../profiles/im
        ../profiles/zsh
      ];

      home.file = {
        ".background-image".source = ../../assets/wallpaper.png;
      };
    };

  users.users.ben = {
    # mkpasswd -m sha-512 hunter1 >> ./ben.hashedPassword
    hashedPassword = lib.fileContents ./ben.hashedPassword;
    isNormalUser = true;
    home = "/home/ben";
    extraGroups =
      [
        "wheel"
        "plugdev"
        "networkmanager"
        "docker"
        "libvirtd"
        "disk"
        config.users.groups.keys.name
      ];
    openssh.authorizedKeys.keyFiles = [
      (./. + (builtins.toPath "/ssh/ben@busc.pub"))
      ./ssh/id_rsa.pub
      ./ssh/witness.pub
      ./ssh/vigilant.pub
    ];
  };
  users.defaultUserShell = pkgs.zsh;
}
