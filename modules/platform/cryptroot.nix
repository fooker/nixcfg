{ config, lib, ... }:

with lib;
{
  options.platform.cryptroot = {
    enable = mkEnableOption "encrypted root";

    device = mkOption {
      type = types.str;
      default = "/dev/disk/by-label/nixos-crypt";
      description = "Encrypted root device";
    };

    # network = {
    #   enable = mkEnableOption "Enable early-boot network";

    # };
  };

  config = mkIf config.platform.cryptroot.enable {
    boot.initrd.availableKernelModules = [
      "aesni_intel"
    ];

    boot.initrd.luks.devices."cryptroot".device = config.platform.cryptroot.device;

    # boot.initrd.network = mkIf config.boot.cryptroot.network.enable {
    #   boot.initrd.network.enable = true;
    #   boot.initrd.network.ssh.enable = true;
    # };
  };
}
