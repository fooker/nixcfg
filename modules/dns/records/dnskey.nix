{ config, lib, ... }:

with lib;

let
  mappings = {
    protocol = {
      DNSSEC = 3;
    };

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
  };

in
{
  options = {
    flags = mkOption {
      type = types.ints.u16;
      description = ''
        16-bit flags field.
      '';
    };

    protocol = mkOption {
      type = types.enum [
        "DNSSEC"
      ];
      description = ''
        The Protocol Field MUST have value 3.
      '';
      default = "DNSSEC";
    };

    algorithm = mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-sec-alg-numbers/dns-sec-alg-numbers.xhtml
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

    publicKey = mkOption {
      type = types.str;
      description = "The public key encoded in base64.";
    };
  };

  config = {
    data = with config; [
      (toString flags)
      (toString mappings.protocol.${protocol})
      (toString mappings.algorithm.${algorithm})
      publicKey
    ];
  };
}
