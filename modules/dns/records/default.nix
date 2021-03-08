{ lib, ext, record, ... }:

with lib;
with ext;

let
  inherit (record) mkValueRecord mkModuleRecord;
in {
  options = {
    SOA = mkModuleRecord "SOA" ./soa.nix {
      singleton = true;
    };

    NS = mkValueRecord "NS" {
      type = types.domain;
    };

    CNAME = mkValueRecord "CNAME" {
      type = types.domain;
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