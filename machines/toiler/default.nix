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
    # ./concourse.nix
  ];

  server.enable = true;

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };

  
}
