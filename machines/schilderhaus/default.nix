{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./kodi.nix
  ];


  #console.enable = false;

  boot.plymouth = {
    enable = true;
  };

  services.journald.extraConfig = "Storage=volatile";

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
