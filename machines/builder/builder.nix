{ config, lib, pkgs, ... }:

{
  imports = [
    ./qemu/qemu.nix
  ];

  qemu-user = {
    arm = true;
    aarch64 = true;
  };

  users.users."root" = {
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../notebook/secrets/id_builder.pub)
    ];
  };
}