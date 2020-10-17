{ pkgs, sources, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    extraOptions = "--debug --iptables=false";

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
