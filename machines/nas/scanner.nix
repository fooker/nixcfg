{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

in
{
  # Used to upload scanned documents from printer
  users.users."scanner" = {
    home = "/mnt/files/scans";
    createHome = true;
    isSystemUser = true;

    shell = "/bin/sh";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyp+ijJxUeY23fr/J+CzBTQvWtBwX6FookGYA24IwI3 scanner@sacnner"
    ];
  };

  backup.paths = [
    config.users.users."scanner".home
  ];
}
