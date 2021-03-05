{ lib, ... }:

with lib;

let
  # Like types.uniq but merge equal definitions
  # This is used to allow multiple nodes to define equla records even if the record is a singleton
  equi = elemType: mkOptionType rec {
    name = "equi";
    inherit (elemType) description check;
    merge = mergeEqualOption;
    emptyValue = elemType.emptyValue;
    getSubOptions = elemType.getSubOptions;
    getSubModules = elemType.getSubModules;
    substSubModules = m: equi (elemType.substSubModules m);
    functor = (defaultFunctor name) // { wrapped = elemType; };
  };

  # Builder for record type options
  mkRecordOption = { type, singleton }: mkOption {
    type = if singleton
      then type
      else types.either type (types.listOf type);
    apply = if singleton
      then id
      else toList;
  };

in rec {
  # The base options for all record types
  recordOptions = {
    ttl = mkOption {
      type = types.nullOr (types.ints.between 0 2147483647);
      default = null;
      description = "Time interval (in seconds) that the resource record may be cached";
    };

    class = lib.mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-parameters/#dns-parameters-2
        "IN" "CH" "HS" "NONE" "ANY"
      ];
      default = "IN";
      description = "The class to use for this record";
    };

    type = lib.mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-parameters/#dns-parameters-4
        "A" "NS" "CNAME" "SOA" "MB" "MG" "MR" "NULL" "WKS" "PTR" "HINFO"
        "MINFO" "MX" "TXT" "RP" "AFSDB" "X25" "ISDN" "RT" "NSAP" "NSAP-PTR"
        "SIG" "KEY" "PX" "GPOS" "AAAA" "LOC" "EID" "NIMLOC" "SRV" "ATMA"
        "NAPTR" "KX" "CERT" "DNAME" "SINK" "OPT" "APL" "DS" "SSHFP" "IPSECKEY"
        "RRSIG" "NSEC" "DNSKEY" "DHCID" "NSEC3" "NSEC3PARAM" "TLSA" "SMIMEA"
        "HIP" "NINFO" "RKEY" "TALINK" "CDS" "CDNSKEY" "OPENPGPKEY" "CSYNC"
        "SPF" "UINFO" "UID" "GID" "UNSPEC" "NID" "L32" "L64" "LP" "EUI48"
        "EUI64" "TKEY" "TSIG" "URI" "CAA" "AVC" "DOA" "TA" "DLV"
      ];
      description = "The record type";
    };

    data = mkOption {
      type = equi (types.nonEmptyListOf types.str);
      internal = true;
    };
  };

  mkValueRecord = rtype: { type, singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.coercedTo type
      (value: { inherit value; })
      (types.submodule ({ config, ... }: {
        options = recordOptions // {
          value = mkOption {
            type = equi type;
            description = "The value of the record";
          };
        };
        config = {
          type = rtype;
          data = [ config.value ];
        };
      }));
  };

  mkModuleRecord = rtype: mod: { singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.submodule {
      imports = [ mod ];
      options = recordOptions;
      config = {
        type = rtype;
      };
    };
  };
}