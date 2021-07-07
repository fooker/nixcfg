{ config, lib, pkgs, ... }:

{
  backup = {
    repo = {
      host = "backup.home.open-desk.net";
      fingerprint = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ58kj0PhHZThJ00tXLwNCFfK8o4RArFcNqtWfaXWto3";
      user = "backup";
    };
  };
}
