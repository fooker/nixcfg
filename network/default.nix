{ lib, ... }:

with lib;

{
  imports = [
    ./sites.nix
    ./devices.nix
    ./prefixes.nix
  ];

  extends."reservation" = { name, ... }: {
    options = {
      dhcp = {
        enable = mkEnableOption "DHCP reservation";

        valid-lifetime = mkOption {
          type = types.nullOr types.ints.positive;
          description = ''
            The lifetime of a DHCP lease.
          '';
          default = null;
        };
      };
    };

    config = {
      dhcp.enable = mkDefault (name == "dhcp");
    };
  };
}
