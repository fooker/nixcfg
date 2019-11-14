{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./nix.nix
    ./i18n.nix
    ./root.nix
    ./network.nix
  ];
}
