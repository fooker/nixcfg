{ config, lib, pkgs, ... }:

with lib;
{
  options.server = {
    enable = mkOption {
        type = types.bool;
        default = false;
    };
  };

  config = mkIf config.server.enable {
    services.openssh.enable = true;
  };
}
