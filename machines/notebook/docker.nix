{ pkgs, sources, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    extraOptions = "--debug --iptables=False";

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
