{ config, lib, pkgs, machine, sources, ... }:

{
  imports = [
    ./qemu/qemu.nix
  ];

  qemu-user = {
    arm = true;
    aarch64 = true;
  };
}