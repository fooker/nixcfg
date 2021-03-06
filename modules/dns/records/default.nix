{ lib, ... }@args:

with lib;
with import ../types.nix args;

{
  options = {
    SOA = mkModuleRecord "SOA" ./soa.nix {
      singleton = true;
    };

    NS = mkValueRecord "NS" {
      type = types.str;
    };

    CNAME = mkValueRecord "CNAME" {
      type = types.str;
      singleton = true;
    };

    CAA = mkModuleRecord "CAA" ./caa.nix {
    };

    SSHFP = mkModuleRecord "SSHFP" ./sshfp.nix {
    };

    A = mkValueRecord "A" {
      type = types.str;
    };

    AAAA = mkValueRecord "AAAA" {
      type = types.str;
    };

    TXT = mkValueRecord "TXT" {
      type = types.str;
    };

    MX = mkModuleRecord "MX" ./mx.nix {
    };

    SRV = mkModuleRecord "SRV" ./srv.nix {
    };
  };
}