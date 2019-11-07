{ config, lib, pkgs, machineConfig, ... }:

{
  imports = [
    ./x86_64-linux.nix # TODO: Import depending on the target platform identifier
  ];
}
