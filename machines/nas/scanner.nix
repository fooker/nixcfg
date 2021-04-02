{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;

in {
  # services.paperless = {
  #   enable = true;

  #   package = pkgs.paperless.overrideAttrs (super: rec {
  #     pname = "paperless-ng";
  #     version = "1.3.2";
      
  #     src = pkgs.fetchFromGitHub {
  #       owner = "jonaswinkler";
  #       repo = "paperless-ng";
  #       rev = "ng-${ version }";
  #       sha256 = "0wdwvb4yysbn6nyjgsvn3sxivjqg90g69h87yh4x2hb03qpgzl8p";
  #     };
  #   });

  #   ocrLanguages = [ "deu" "eng" ];

  #   extraConfig = {
  #     PAPERLESS_MEDIA_ROOT = "/mnt/docs";
  #   };
  # };

  # systemd.services.paperless-server = {
  #   unitConfig = {
  #     RequiresMountsFor = "/mnt/docs";
  #   };
  # };

  # reverse-proxy = {
  #   enable = true;
  #   hosts = {
  #     "paperless" = {
  #       domains = [ "paperless.home.open-desk.net" ];
  #       target = "http://[::1]:${ toString config.services.paperless.port }/";
  #     };
  #   };
  # };

  # Used to upload scanned documents from printer
  users.users."scanner" = {
    home = "/mnt/files/scans";
    createHome = true;

    shell = "/bin/sh";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAyp+ijJxUeY23fr/J+CzBTQvWtBwX6FookGYA24IwI3 scanner@sacnner"
    ];
  };

  backup.paths = [
    config.users.users."scanner".home
    # config.services.paperless.dataDir
    # "/mnt/docs"
  ];
}
