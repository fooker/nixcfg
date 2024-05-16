{ config, lib, private, ... }:

with lib;

{
  backup.targets = {
    "default" = job: _: {
      host = "backup.home.open-desk.net";
      fingerprint = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ58kj0PhHZThJ00tXLwNCFfK8o4RArFcNqtWfaXWto3";
      user = "backup";
      path = job.name;
    };
    "borgbase" = job: { user }: {
      host = "${user}.repo.borgbase.com";
      fingerprint = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMS3185JdDy7ffnr0nLWqVy8FaAQeVh1QYUSiNpW5ESq";
      inherit user;
      path = "./repo";
    };
  };
}
