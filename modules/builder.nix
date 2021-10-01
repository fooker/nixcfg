{ config, lib, nodes, ... }:

with lib;

let
  # Collect all systems used by all nodes and emulate them if they are not
  # native to the builders system
  emulatedSystems = unique (filter
    (system: system != config.nixpkgs.localSystem.system)
    (map
      (node: node.config.nixpkgs.localSystem.system)
      (attrValues nodes)));

in
{
  options.builder = {
    enable = mkEnableOption "machine for distributed building";
  };

  config = mkIf config.builder.enable {
    boot.binfmt.emulatedSystems = emulatedSystems;

    users.users."root" = {
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../machines/notebook/secrets/id_builder.pub)
      ];
    };
  };
}
