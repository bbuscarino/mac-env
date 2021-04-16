{ inputs }: { ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    sharedModules = [
      inputs.nix-doom-emacs.hmModule
    ];
  };
}
