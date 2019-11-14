{ config, lib, pkgs, machineConfig, ... }:

with lib;
{
  options.commons.i18n = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.commons.i18n.enable {
    time.timeZone = "Europe/Berlin";
  };
}
