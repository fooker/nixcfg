{ config, lib, ... }:

with lib;

let
  secrets = import ../../secrets.nix;
in
{
  options.common.root = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.common.root.enable {
    users.users."root" = {
      inherit (secrets.users.root) hashedPassword;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ fooker@k-2so"
      ];
    };
  };
}
