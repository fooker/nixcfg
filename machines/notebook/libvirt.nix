{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "en" ];
  };

  security.polkit.enable = true;
}
