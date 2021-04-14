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
    (final: prev:
      let
        old = prev.lib.dev.os.pkgImport inputs.nixos-2003 [ ] prev.system;
      in
      {
        gstreamer = old.gstreamer;
        gst_plugins_base = old.gst_plugins_base;
      })
    (final: prev: {
      deploy-rs = deploy.packages.${prev.system}.deploy-rs;
    })
  ];

  # passed to all nixos modules
  specialArgs = {
    overrideModulesPath = "${override}/nixos/modules";
    hardware = nixos-hardware.nixosModules;
    sopsModule = sops-nix.nixosModules.sops;
    mobile = mobile-nixos.nixosModules;
  };
  # added to home-manager
  userModules = [
    nix-doom-emacs.hmModule
  ];

  # passed to all home-manager modules
  userSpecialArgs = { };
}
