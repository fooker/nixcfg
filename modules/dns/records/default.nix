{ lib, record, ... }:

with lib;

let
  inherit (record) mkValueRecord mkModuleRecord;
in
{
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

    CAA = mkModuleRecord "CAA" ./caa.nix { };

    SSHFP = mkModuleRecord "SSHFP" ./sshfp.nix { };

    A = mkValueRecord "A" {
      type = types.ip.address.v4;
    };

    AAAA = mkValueRecord "AAAA" {
      type = types.ip.address.v6;
    };

    TXT = mkValueRecord "TXT" {
      type = types.str;
      apply = value: "\"${ value }\"";
    };

    MX = mkModuleRecord "MX" ./mx.nix { };

    SRV = mkModuleRecord "SRV" ./srv.nix { };

    DNSKEY = mkModuleRecord "DNSKEY" ./dnskey.nix { };

    DS = mkModuleRecord "DS" ./ds.nix { };
  };
}
