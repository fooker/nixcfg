{
  target = {
    host = "hetzner.arm.builder.dev.open-desk.net";
    user = "root";
  };

  tags = [ "prod" ];

  system = "aarch64-linux";

  stateVersion = "25.05";
}
