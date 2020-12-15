{ config, lib, pkgs, ... }:

with lib;

{
  options.builder = {
    enable = mkEnableOption "machine for distributed building";
  };

  config = mkIf config.builder.enable {
    boot.binfmt.emulatedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
    ];

    users.users."root" = {
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../machines/notebook/secrets/id_builder.pub)
      ];
    };
  };
}