{ config, lib, pkgs, ... }:

with lib;
{
  config = {
    programs = {
      vim.defaultEditor = true;
    };

    services.timesyncd = {
      enable = true;
      servers = [
        "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org"
        "81.7.16.52" "185.220.101.34" "213.239.239.165" "46.4.34.242"
      ];
    };
  };
}
