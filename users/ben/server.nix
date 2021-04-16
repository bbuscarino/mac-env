{ lib, ... }:
{
  imports = [
    ./default.nix
  ];


  home-manager.users.ben = lib.mkForce ({ home, ... }:
    {
      imports = [
        ../profiles/develop
        ../profiles/develop/nix
        ../profiles/develop/purescript
        ../profiles/develop/python
        ../profiles/develop/flutter
        ../profiles/direnv
        ../profiles/emacs
        ../profiles/git
        ../profiles/gpg
        ../profiles/zsh
      ];
    });
}
