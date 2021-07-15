{ config, lib, ... }:

with lib;

let
  mappings = {
    algorithm = {
      rsa = 1;
      dsa = 2;
      ecdsa = 3;
      ed25519 = 4;
    };

    hash = {
      sha1 = 1;
      sha256 = 2;
    };
  };

in
{
  options = {
    algorithm = mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-sshfp-rr-parameters/
        "rsa"
        "dsa"
        "ecdsa"
        "ed25519"
      ];
      description = ''
        The algorithm of the public key.
      '';
    };

    hash = mkOption {
      type = types.enum [
        # https://www.iana.org/assignments/dns-sshfp-rr-parameters/
        "sha1"
        "sha256"
      ];
      description = ''
        The message-digest algorithm used to calculate the fingerprint.
      '';
    };

    fingerprint = mkOption {
      type = lib.mkOptionType {
        name = "hexEncodedHash";
        description = "hex-encoded hash";
        check = x: lib.isString x
          && builtins.match "([a-fA-F0-9]{2})+" x != null;
        merge = lib.mergeOneOption;
      };
      example = "c56e95d1a3015e55ad38b25e59867dc5d12f73ca";
      description = "The fingerprint of the public key.";
    };
  };

  config = {
    data = with config; [
      (toString mappings.algorithm.${algorithm})
      (toString mappings.hash.${hash})
      fingerprint
    ];
  };
}
