{ pkgs, config, lib, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf optionals;
in
{
  programs.doom-emacs =
    let
      emacs = pkgs.emacsGcc;
    in 
    {
    enable = true;
    package = emacs;
    doomPrivateDir = ./.doom.d;
    # extraPackages = with (pkgs.emacsPackagesFor emacs); [ vterm ];
  };
  home = {
    sessionPath = [ "$HOME/.emacs.d/bin" ];
    sessionVariables.EMACS = "${config.programs.emacs.finalPackage}/bin/emacs";
  };

  # Install MacOS applications to the user environment if the targetPlatform is Darwin
  home.file."Applications/home-manager" =
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in
    mkIf isDarwin {
      source = "${apps}/Applications";
    };

  home.packages = with pkgs;
    [
      # Doom dependencies
      ripgrep
      fd
      emacs-all-the-icons-fonts
      ispell
      (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))


      # Languages
      nodePackages.dockerfile-language-server-nodejs

      rnix-lsp
      llvm # Includes clangd
      nodePackages.bash-language-server

      sqlite
      git
    ] ++ optionals isLinux (with pkgs; [
      libvterm
      xdotool
      xorg.xwininfo
    ]);
}
