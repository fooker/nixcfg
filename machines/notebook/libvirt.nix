{ lib, ... }:

with lib;

{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "en" ];
  };

  security.polkit.enable = true;

  firewall.rules = dag: with dag; {
    inet.filter.forward = {
      virt = before [ "drop" ] ''
        iifname virbr*
        counter
        accept
      '';
    };
    inet.filter.input = {
      virt = between [ "established" ] [ "drop" ] [
        ''iifname virbr* udp dport { 53, 67 } accept''
        ''iifname virbr* tcp dport { 53, 67 } accept''
      ];
    };
    inet.nat.postrouting = {
      virt = anywhere ''
        ip saddr 192.168.122.0/24
        ip daddr != 192.168.122.0/24
        counter
        masquerade
      '';
    };
  };

}
