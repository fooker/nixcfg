{ config, lib, ... }:

with lib;

{
  options = {
    critical = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set to <literal>true</literal>, indicates that the values specified
        must be fully understood by the issuer, otherwise issuers must not issue
        certificates for this domain.
      '';
    };

    tag = mkOption {
      type = types.enum [
        "issue"
        "issueWild"
        "iodef"
      ];
      description = ''
        issue:
          Authorizes the holder of the given domain name or a party acting under
          the explicit authority of the holder of that domain name to issue
          certificates for the current domain.
          The given domain name has to be a fully qualified domain name.

        issueWild:
          Authorizes the holder of the given domain name or a party acting under
          the explicit authority of the holder of that domain name to issue
          wildcard certificates for the current domain.
          The given domain name has to be a fully qualified domain name.

        iodef:
          Specifies a URL to which an issuer may report certificate issue requests
          that are inconsistent with the issuer's certification practices or
          certificate policy, or that a certificate evaluator may use to report
          observation of a possible policy violation.
      '';
    };

    value = mkOption {
      type = types.str;
      description = ''
        The value associated with the chosen property tag.
      '';
    };
  };

  config = {
    data = with config; [
      (toString (if critical then 128 else 0))
      (toString tag)
      "\"${(toString value)}\""
    ];
  };
}
