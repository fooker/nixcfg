{ pkgs, ... }:

let
  secrets = import ./secrets.nix;

  mmv = pkgs.callPackage ../../packages/mmv.nix { };
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
  ];

  server.enable = true;
  serial.enable = true;

  backup.passphrase = secrets.backup.passphrase;

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
