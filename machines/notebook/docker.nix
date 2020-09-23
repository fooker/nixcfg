{ pkgs, sources, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    extraOptions = "--debug";

    autoPrune = {
      enable = true;
      flags = [ "--all" ];
    };
  };

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}
