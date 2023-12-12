{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./network.nix
    ./kodi.nix
  ];

  serial.enable = true;
  serial.unit = "S1";

  #server.enable = true;

  #console.enable = false;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  services.journald.extraConfig = "Storage=volatile";

  dns.host = {
    realm = "home";
    interface = "priv";
  };
}
