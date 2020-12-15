{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./jellyfin.nix
    ./pulseaudio.nix
    ./mopidy.nix
    ./spotifyd.nix
    ./user.nix
    ./gitea.nix
    ./drone.nix
  ];

  server.enable = true;
  builder.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  
}
