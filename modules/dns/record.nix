{ lib, ... }:

with lib;

rec {
  # Builder for record type options
  mkRecordOption = { type, singleton }: mkOption {
    type =
      if singleton
      then type
      else types.either type (types.listOf type);
    apply =
      if singleton
      then id
      else toList;
  };

  # A simple record type containing a single value
  mkValueRecord = rtype: { type, apply ? id, singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.coercedTo type
      (value: { inherit value; })
      (types.submodule ({ config, ... }: {
        imports = [ module ];
        options = {
          value = mkOption {
            type = types.equi type;
            description = "The value of the record";
          };
        };
        config = {
          type = rtype;
          data = [ (apply config.value) ];
        };
      }));
  };

  # A record type containing whereas the data is defined by a module
  mkModuleRecord = rtype: mod: { singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.submodule {
      imports = [ module mod ];
      config = {
        type = rtype;
      };
    };
  };

  # The base module for all record types
  module = {
    options = {
      ttl = mkOption {
        type = types.nullOr (types.ints.between 0 2147483647);
        default = null;
        description = "Time interval (in seconds) that the resource record may be cached";
      };

      class = mkOption {
        type = types.enum [
          # https://www.iana.org/assignments/dns-parameters/#dns-parameters-2
          "IN"
          "CH"
          "HS"
          "NONE"
          "ANY"
        ];
        default = "IN";
        description = "The class to use for this record";
      };

      type = mkOption {
        type = types.enum [
          # https://www.iana.org/assignments/dns-parameters/#dns-parameters-4
          "A"
          "NS"
          "CNAME"
          "SOA"
          "MB"
          "MG"
          "MR"
          "NULL"
          "WKS"
          "PTR"
          "HINFO"
          "MINFO"
          "MX"
          "TXT"
          "RP"
          "AFSDB"
          "X25"
          "ISDN"
          "RT"
          "NSAP"
          "NSAP-PTR"
          "SIG"
          "KEY"
          "PX"
          "GPOS"
          "AAAA"
          "LOC"
          "EID"
          "NIMLOC"
          "SRV"
          "ATMA"
          "NAPTR"
          "KX"
          "CERT"
          "DNAME"
          "SINK"
          "OPT"
          "APL"
          "DS"
          "SSHFP"
          "IPSECKEY"
          "RRSIG"
          "NSEC"
          "DNSKEY"
          "DHCID"
          "NSEC3"
          "NSEC3PARAM"
          "TLSA"
          "SMIMEA"
          "HIP"
          "NINFO"
          "RKEY"
          "TALINK"
          "CDS"
          "CDNSKEY"
          "OPENPGPKEY"
          "CSYNC"
          "SPF"
          "UINFO"
          "UID"
          "GID"
          "UNSPEC"
          "NID"
          "L32"
          "L64"
          "LP"
          "EUI48"
          "EUI64"
          "TKEY"
          "TSIG"
          "URI"
          "CAA"
          "AVC"
          "DOA"
          "TA"
          "DLV"
        ];
        description = "The record type";
      };

      data = mkOption {
        type = types.equi (types.nonEmptyListOf types.str);
        internal = true;
      };
    };
  };
}
