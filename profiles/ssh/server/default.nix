{ lib, ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
  };
  programs.ssh.extraConfig = lib.fileContents ../config;
}
