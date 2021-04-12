{ inputs }: with inputs;
{
  modules = [
    home.nixosModules.home-manager
    ci-agent.nixosModules.agent-profile
  ];

  overlays = [
    emacs.overlay
    nur.overlay
    devshell.overlay
    sops-nix.overlay
    (final: prev: {
      deploy-rs = deploy.packages.${prev.system}.deploy-rs;
    })
  ];

  # passed to all nixos modules
  specialArgs = {
    overrideModulesPath = "${override}/nixos/modules";
    hardware = nixos-hardware.nixosModules;
    sopsModule = sops-nix.nixosModules.sops;
  };
  # added to home-manager
  userModules = [
    nix-doom-emacs.hmModule
  ];

  # passed to all home-manager modules
  userSpecialArgs = { };
}
