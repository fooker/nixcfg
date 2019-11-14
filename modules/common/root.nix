{ config, lib, pkgs, ... }:

with lib;
{
  options.commons.root = {
    enable = mkOption {
        type = types.bool;
        default = true;
    };
  };

  config = mkIf config.commons.root.enable {
    users.users.root = {
      hashedPassword = "$6$3S/rgJ8.Dz7ak$UeqTgpMfIVAZK3.82QgisbZFmyhPE1f9JNEACx8agIJkNIPECNY5cXaqCiTFxo0PRM/Jhch/qjVLlpCH1C/Lr.";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ fooker@k-2so"
      ];
    };
  };
}
