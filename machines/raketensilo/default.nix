{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./network.nix
    ./bitmagnet.nix
  ];

  server.enable = true;

  dns.host = {
    realm = "hs";
    interface = "int";
  };

  environment.systemPackages = with pkgs; [
    jq
  ];
}
