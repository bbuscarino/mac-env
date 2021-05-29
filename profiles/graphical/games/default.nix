{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    minecraft
    # eve-online
    pyfa
  ];

  programs.steam.enable = true;

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };
}
