{ config, lib, pkgs, path, ... }:

with lib;

{
  options.server = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.server.enable {
    # Reboot on panic
    boot.kernelParams = [ "panic=1" "boot.panic_on_fail" ];
  };
}
