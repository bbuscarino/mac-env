{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemuRunAsRoot = false;
  };
  virtualisation.docker.enable = true;

  # you'll need to add your user to 'libvirtd' group to use virt-manager
  environment.systemPackages = with pkgs; [ virt-manager docker-compose docker win-virtio ];
}
