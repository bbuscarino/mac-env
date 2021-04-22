{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      nodePackages.purescript-language-server
      #purs
      #spago
      #pulp
      #purty
      #purp
    ];
}
