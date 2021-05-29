{
  services.resolved = {
    enable = true;
    fallbackDns = [
      # Google
      "8.8.8.8"
      "8.8.4.4"
      # CloudFlare
      "1.1.1.1"
    ];
  };
}
