{ pkgs, inputs, ... }:

let
  mmv = pkgs.callPackage ../../packages/mmv.nix { inherit inputs; };
in
{
  imports = [
    ./hardware.nix
    ./network.nix
    ./vault.nix
    ./shares.nix
    ./deluge.nix
    ./syncthing.nix
    ./backup.nix
    ./scanner.nix
    ./c3sets.nix
  ];

  server.enable = true;
  serial.enable = true;

  dns.host = {
    realm = "home";
    interface = "priv";
  };

  environment.systemPackages = with pkgs; [
    mmv

    unrar
    unzip
  ];
}
