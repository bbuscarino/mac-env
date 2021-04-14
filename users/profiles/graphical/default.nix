{ pkgs, ... }: {
  home.packages = with pkgs; [
    chromium
    libreoffice
    gnucash
    # Media
    spotify
    # Utilities
    gnome3.networkmanagerapplet
  ];


  gtk = {
    enable = true;
    theme.name = "Breeze-Dark";
    iconTheme.name = "breeze-dark";
  };
}
