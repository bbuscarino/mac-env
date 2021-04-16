{ lib, ... }:
{
  imports = [
    ./default.nix
  ];


  home-manager.users.ben = lib.mkForce ({ home, ... }:
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
        ../profiles/graphical/sway
        #../profiles/xmonad
        ../profiles/im
        ../profiles/zsh
      ];

      home.file = {
        ".background-image".source = ../../assets/wallpaper.png;
      };
    });
}
