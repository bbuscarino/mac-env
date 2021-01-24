{ pkgs, ... }:
let
  tangle = file:
    let
      tangled =
        pkgs.runCommand "tangle" { buildInputs = [ pkgs.emacs-nox ]; } ''
          mkdir -p $out
          cd $out
          cp ${file} .spacemacs.org
          emacs --batch -l ob-tangle --eval "(org-babel-tangle-file \".spacemacs.org\")"
          mv .spacemacs.el .spacemacs
        '';
    in
    "${tangled}/.spacemacs";
in
{
  home.file = {
    ".emacs.d" = {
      source = pkgs.fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "6ce1dc88fc74810223711faa64bb331cce0a97b8";
        sha256 = "sha256-oVe19bP8V8RozENtDHgGR6iVQ8DiccZJtVmLOK5CWzk=";
        fetchSubmodules = true;
      };
      recursive = true;
    };
    ".spacemacs.d/layers/exwm".source = pkgs.fetchFromGitHub {
      owner = "timor";
      repo = "spacemacsOS";
      rev = "d8ce7d6c8fab42bffeb157f850a36b258f6a8934";
      sha256 = "v+8HwtANhVSAGjyNA2vudFRzgo6+SHvEZfRYjPsM0O4=";
      fetchSubmodules = true;
    };
    ".spacemacs".source = tangle ./.spacemacs.org;
  };

  home.packages = with pkgs; [
    emacs-all-the-icons-fonts

    pandoc

    xclip
    samba

    ispell
    aspell
    hunspell
    aspellDicts.en
    aspellDicts.en-computers

    sqlite

    emacsGcc

    # (import ./spacemacs-with-packages.nix { inherit pkgs; } {
    #   layers = import ./layers.nix;
    #   themes = import ./themes.nix;
    #   emacsPackage = pkgs.emacsGcc;
    #   extraPackages =
    #     (epkgs: with epkgs; [ doom-themes direnv company-lsp org-jira ]);
    # })
  ];
}