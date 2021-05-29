{
  description = "A highly structured configuration database.";

  inputs =
    {
      nixos.url = "nixpkgs/nixos-unstable";
      unstable.url = "nixpkgs";
      ci-agent.url = "github:hercules-ci/hercules-ci-agent";
      darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs-darwin";
      };
      nixpkgs-darwin.url = "nixpkgs/nixpkgs-20.09-darwin";
      deploy = {
        url = "github:serokell/deploy-rs";
        inputs = { flake-compat.follows = "flake-compat"; naersk.follows = "naersk"; nixpkgs.follows = "unstable"; utils.follows = "utils"; };
      };
      doom-emacs = {
        url = "github:hlissner/doom-emacs/develop";
        flake = false;
      };
      emacs.url = "github:nix-community/emacs-overlay";
      flake-compat.url = "github:BBBSnowball/flake-compat/pr-1";
      flake-compat.flake = false;
      nix-doom-emacs = {
        url = "github:vlaci/nix-doom-emacs";
        inputs.doom-emacs.follows = "doom-emacs";
      };
      utils.url = "github:gytis-ivaskevicius/flake-utils-plus/staging";
      home = {
        url = "github:nix-community/home-manager?rev=0a6227d667d1d2bc6a79de24fd12becc523f2e2f";
        inputs.nixpkgs.follows = "nixos";
      };
      nur.url = "github:nix-community/NUR";
      naersk.url = "github:nmattia/naersk?rev=32e3ba39d9d83098b13720a4384bdda191dd0445";
      naersk.inputs.nixpkgs.follows = "unstable";
      nixos-hardware.url = "github:nixos/nixos-hardware";
      sops-nix.url = "github:Mic92/sops-nix";
      nixos-2003.url = "nixpkgs/nixos-20.03";
      mobile-nixos.url = "github:bbuscarino/mobile-nixos/flakes";
    };

  outputs = inputs@{ nixos, self, utils, ... }:
    let
      nixosHost = args@{ modules ? [ ], extraArgs ? { inherit inputs; }, ... }: args // {
        modules = modules ++ [
          inputs.home.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.ci-agent.nixosModules.agent-profile
          ./modules/secrets.nix
          ./cachix.nix
        ] ++ map builtins.import (import ./modules/module-list.nix);
        extraArgs = extraArgs // { hardware = inputs.nixos-hardware.nixosModules; };
      };
    in
    utils.lib.systemFlake
      {
        inherit self inputs;

        supportedSystems = [ "armv6l-linux" "aarch64-linux" "x86_64-linux" "x86_64-darwin" ];

        channels = with inputs; {
          nixpkgs = {
            input = nixos;
            overlaysBuilder = channels: [ (import ./overrides channels.unstable) ];
          };
          unstable.input = unstable;
          nixos-2003.input = nixos-2003;
          nixpkgs-darwin.input = nixpkgs-darwin;
        };

        channelsConfig = {
          allowUnfree = true;
        };

        sharedModules = [
          (import ./modules/home.nix { inherit inputs; })
        ];

        sharedOverlays = [
          inputs.emacs.overlay
          inputs.nur.overlay
          inputs.sops-nix.overlay
          (final: prev: {
            deploy-rs = inputs.deploy.packages.${prev.system}.deploy-rs;
          })
          (final: prev:
            let
              old = import inputs.nixos-2003 { system = prev.system; };
            in
            {
              gstreamer = old.gstreamer;
              gst_plugins_base = old.gst_plugins_base;
            })
          # Overlays
          (import ./pkgs)
        ] ++ (map builtins.import (nixos.lib.filesystem.listFilesRecursive ./overlays));

        hosts = {
          witness = nixosHost {
            modules = with inputs.nixos-hardware.nixosModules; [
              ./hosts/witness.nix
              common-cpu-amd
              common-gpu-nvidia
              common-pc
              common-pc-ssd
            ];
          };
          vigilant = nixosHost {
            modules = with inputs.nixos-hardware.nixosModules; [
              ./hosts/vigilant.nix
              common-cpu-amd
              common-pc
              common-pc-ssd
              lenovo-thinkpad-t14s
            ];
          };
          rpi = nixosHost {
            modules = [ ./hosts/rpi.nix ];
          };
          proof = nixosHost {
            system = "aarch64-linux";
            modules = [ ./hosts/proof.nix inputs.mobile-nixos.nixosModules.pine64-pinephone ];
          };
        };

      } // {
      #mobileConfigurations.proof = nixos.lib;
      images = {
        proof =
          let
            dev = self.nixosConfigurations.proof.config.system.build;
          in
          (import nixos { system = "aarch64-linux"; }).runCommandNoCC "pinephone-bundle" { } ''
            mkdir $out
            ln -s "${dev.disk-image}" $out/disk-image;
            ln -s "${dev.u-boot}" $out/uboot;
            ln -s "${dev.boot-partition}" $out/boot-partition;
          '';
        rpi = self.nixosConfigurations.rpi.config.system.build.sdImage;
      };
      defaultTemplate = self.templates.flk;
      templates.flk.path = ./.;
      templates.flk.description = "inspired by many things";
    };
}
