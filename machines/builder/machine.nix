{
  target = {
    host = "nixos-builder";
    user = "root";
  };

  tags = [ "deployed" ];

  system = "x86_64-linux";
  
  stateVersion = "19.09";
}
