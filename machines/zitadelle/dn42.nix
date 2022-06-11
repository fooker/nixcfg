{ lib, ... }:

with lib;

{
  # Enable peering info for DN42 peers
  peering.info = {
    enable = true;
    domains = [ "dn42" ];
  };

  # Check RoA 

}
