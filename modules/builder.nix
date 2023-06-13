{ pkgs, lib, config, nodes, ... }:

with lib;

{
  options.builder = {
    enable = mkEnableOption "machine for distributed building";

    emulatedSystems = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of systems to emulate for building.
      '';
    };

    systems = mkOption {
      type = types.listOf types.str;
      readOnly = true;
      description = ''
        List of systems this machine supports building for.
      '';
      default = [ config.nixpkgs.localSystem.system ] ++ config.builder.emulatedSystems;
    };
  };

  config = mkIf config.builder.enable {
    boot.binfmt.emulatedSystems = config.builder.emulatedSystems;

    users.users."root" = {
      openssh.authorizedKeys.keys = [
        (fileContents nodes."notebook".config.gather.parts."builder/sshKey".path)
      ];
    };
  };
}
