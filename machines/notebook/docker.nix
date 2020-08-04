{ pkgs, sources, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
}
