{
  target = {
    host = "nixos-builder";
    user = "root";
  };

  tags = [ "prod" ];

  system = "x86_64-linux";

  stateVersion = "19.09";
}
