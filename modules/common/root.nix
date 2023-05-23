{ config, lib, pkgs, ... }:

with lib;

{
  options.common.root = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.common.root.enable {
    users.users."root" = {
      shell = pkgs.zsh;

      passwordFile = config.sops.secrets."users/root/password".path;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK2nkarN0+uSuP5sGwDCb9KRu+FCjO/+da4VypGanPUZ fooker@k-2so"
      ];
    };

    programs.zsh = {
      enable = true;

      histSize = 10000;

      ohMyZsh = {
        enable = true;
        theme = "gentoo";
      };
    };

    sops.secrets."users/root/password" = {
      sopsFile = ../../secrets.yaml;
      neededForUsers = true;
    };
  };
}
