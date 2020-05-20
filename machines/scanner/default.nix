{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./scanner.nix
  ];

  boot.type = "extlinux";
  serial.enable = true;
  server.enable = true;

  services.journald.extraConfig = "Storage=volatile";

  backup = {
    enable = true;
    passphrase = secrets.backup.passphrase;
  };
}
