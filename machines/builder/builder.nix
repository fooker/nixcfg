{ config, lib, pkgs, ... }:

{
  imports = [
    ./qemu/qemu.nix
  ];

  qemu-user = {
    arm = true;
    aarch64 = true;
  };
}