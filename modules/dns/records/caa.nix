{ config, lib, ext, ... }:

with lib;
with ext;

{
  options = {
    critical = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set to <literal>true</literal>, indicates that the values specified in
        either <option>issue</option>, <option>issueWild</option>,
        <option>iodef</option> or <option>properties</option> must be fully
        understood by the issuer, otherwise issuers must not issue certificates
        for this domain.
      '';
    };

    issue = mkOption {
      type = types.str;
      description = ''
        Authorizes the holder of the given domain name or a party acting under
        the explicit authority of the holder of that domain name to issue
        certificates for the current domain.
        The given domain name has to be a fully qualified domain name.
      '';
    };

    issueWild = mkOption {
      type = types.str;
      description = ''
        Authorizes the holder of the given domain name or a party acting under
        the explicit authority of the holder of that domain name to issue
        wildcard certificates for the current domain.
        The given domain name has to be a fully qualified domain name.
      '';
    };

    iodef = mkOption {
      type = types.str;
      description = ''
        Specifies a URL to which an issuer may report certificate issue requests
        that are inconsistent with the issuer's certification practices or
        certificate policy, or that a certificate evaluator may use to report
        observation of a possible policy violation.
      '';
    };

    properties = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        These are custom properties that might be specific to an issuer, like for
        example to ensure that only extended validation certificates are issued.
      '';
    };
  };

  config = {
    data = with config; [
      # TODO
    ];
  };
}