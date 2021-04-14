{
  description = "A highly structured configuration database.";

  inputs =
    {
      nixos.url = "nixpkgs";
      override.url = "nixpkgs";
      ci-agent = {
        url = "github:hercules-ci/hercules-ci-agent";
        inputs = { nix-darwin.follows = "darwin"; flake-compat.follows = "flake-compat"; nixos-20_09.follows = "nixos"; nixos-unstable.follows = "override"; };
      };
      darwin.url = "github:LnL7/nix-darwin";
      darwin.inputs.nixpkgs.follows = "override";
      deploy = {
        url = "github:serokell/deploy-rs";
        inputs = { flake-compat.follows = "flake-compat"; naersk.follows = "naersk"; nixpkgs.follows = "override"; utils.follows = "utils"; };
      };
      devshell.url = "github:numtide/devshell";
      doom-emacs = {
        url = "github:hlissner/doom-emacs/develop";
        flake = false;
      };
      emacs.url = "github:nix-community/emacs-overlay";
      nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
      nix-doom-emacs.inputs.doom-emacs.follows = "doom-emacs";
      flake-compat.url = "github:BBBSnowball/flake-compat/pr-1";
      flake-compat.flake = false;
      home.url = "github:nix-community/home-manager";
      home.inputs.nixpkgs.follows = "nixos";
      nur.url = "github:nix-community/NUR";
      naersk.url = "github:nmattia/naersk";
      naersk.inputs.nixpkgs.follows = "override";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      sops-nix.url = "github:Mic92/sops-nix";
      utils.url = "github:numtide/flake-utils";
      pkgs.url = "path:./pkgs";
      pkgs.inputs.nixpkgs.follows = "nixos";
      nixos-2003.url = "nixpkgs/nixos-20.03";
      mobile-nixos.url = "github:bbuscarino/mobile-nixos/flakes";
    };

  outputs = inputs@{ nixos, self, utils, ... }:
    let
      lib = import ./lib { inherit self nixos utils inputs; };
    in
    lib.mkFlake
      {
        inherit self;
        hosts = ./hosts;
        packages = import ./pkgs;
        suites = import ./suites;
        extern = import ./extern;
        overrides = import ./overrides;
        overlays = ./overlays;
        profiles = ./profiles;
        userProfiles = ./users/profiles;
        modules = import ./modules/module-list.nix;
        userModules = import ./users/modules/module-list.nix;
      } // {
      inherit lib;
      defaultTemplate = self.templates.flk;
      templates.flk.path = ./.;
      templates.flk.description = "flk template";
    };
}
