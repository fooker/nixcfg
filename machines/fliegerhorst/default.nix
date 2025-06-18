{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./bitmagnet.nix
    ./minecraft.nix
  ];

  server.enable = true;

  dns.host = {
    interface = "ext";
  };
}
