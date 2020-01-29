{ config, lib, pkgs, machineConfig, ... }:

with lib;
{
  config = {
    programs = {
      vim.defaultEditor = true;
    };
  };
}
