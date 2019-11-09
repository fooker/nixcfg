{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  imports = [
    ./hardware.nix
    ./network.nix
    ./pppd.nix
    ./unbound.nix
  ];

  environment.systemPackages = with pkgs; [
    wget vim
  ];

  services.openssh.enable = true;
}
