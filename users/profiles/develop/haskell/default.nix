{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ormolu
    haskellPackages.haskell-language-server
    stack
    ghc
  ];
}
