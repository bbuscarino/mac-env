{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    minecraft
    eve-online
    pyfa
  ];

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };
}
