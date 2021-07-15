{ config, lib, ... }:

with lib;

let
  mappings = {
    algorithm = {
      "DELETE" = 0;
      "RSAMD5" = 1;
      "DH" = 2;
      "DSA" = 3;
      "RSASHA1" = 5;
      "DSA-NSEC3-SHA1" = 6;
      "RSASHA1-NSEC3-SHA1" = 7;
      "RSASHA256" = 8;
      "RSASHA512" = 10;
      "ECC-GOST" = 12;
      "ECDSAP256SHA256" = 13;
      "ECDSAP384SHA384" = 14;
      "ED25519" = 15;
      "ED448" = 16;
    };

    digestType = {
      "SHA-1" = 1;
      "SHA-256" = 2;
      "GOST R 34.11-94" = 3;
      "SHA-384" = 4;
    };
  };

in
{
  options = {
    keyTag = mkOption {
      type = types.ints.u16;
      default = 0;
      description = ''
        The key tag value that is used to determine which key to use to verify signatures.
      '';
    };

    algorithm = mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-sec-alg-numbers
        "DELETE"
        "RSAMD5"
        "DH"
        "DSA"
        "RSASHA1"
        "DSA-NSEC3-SHA1"
        "RSASHA1-NSEC3-SHA1"
        "RSASHA256"
        "RSASHA512"
        "ECC-GOST"
        "ECDSAP256SHA256"
        "ECDSAP384SHA384"
        "ED25519"
        "ED448"
      ];
      description = ''
        The Algorithm field identifies the public key's cryptographic algorithm.
      '';
    };

    digestType = mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/ds-rr-types/
        "SHA-1"
        "SHA-256"
        "GOST R 34.11-94"
        "SHA-384"
      ];
      description = ''
        Identifies the algorithm used to construct the digest.
      '';
    };

    digest = mkOption {
      type = lib.mkOptionType {
        name = "hexEncodedHash";
        description = "hex-encoded hash";
        check = x: lib.isString x
          && builtins.match "([a-fA-F0-9]{2})+" x != null;
        merge = lib.mergeOneOption;
      };
      description = "The digest.";
    };
  };

  config = {
    data = with config; [
      (toString keyTag)
      (toString mappings.algorithm.${algorithm})
      (toString mappings.digestType.${digestType})
      digest
    ];
  };
}
