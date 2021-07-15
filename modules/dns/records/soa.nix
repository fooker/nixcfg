{ config, lib, ... }:

with lib;

{
  options = {
    mname = mkOption {
      type = types.domain;
      default = "ns";
      description = ''
        The domain name of the name server that was the original or primary
        source of data for this zone.
      '';
    };

    rname = mkOption {
      type = types.domain;
      default = "hostmaster";
      description = ''
        A domain name which specifies the mailbox of the person responsible
        for this zone.
      '';
    };

    serial = mkOption {
      type = types.int;
      default = 0;
      example = 1209600;
      description = ''
        The unsigned 32 bit version number of the original copy of the
        zone. Zone transfers preserve this value. This value wraps and will
        be compared using sequence space arithmetic.
        <note><para>The value <literal>null</literal> automatically generates
        generates a serial entry, which depends on the zone generation module.
        If you run multiple name servers with are serving the same zone but are
        otherwise independent of each other (no zone transfer), you might want to
        set this to some constant value, because you might run into
        synchronization issues otherwise.</para></note>
      '';
    };

    refresh = mkOption {
      type = types.int;
      default = 28800;
      description = ''
        A 32 bit time interval before the zone should be refreshed.
      '';
    };

    retry = mkOption {
      type = types.int;
      default = 7200;
      description = ''
        A 32 bit time interval that should elapse before a failed refresh
        should be retried.
      '';
    };

    expire = mkOption {
      type = types.int;
      default = 604800;
      description = ''
        A 32 bit time value that specifies the upper limit on the time
        interval that can elapse before the zone is no longer
        authoritative.
      '';
    };

    minimum = mkOption {
      type = types.int;
      default = 86400;
      description = ''
        The unsigned 32 bit minimum TTL field that should be exported with
        any resource record from this zone.
      '';
    };
  };

  config = {
    data = with config; [
      mname
      rname
      (toString serial)
      (toString refresh)
      (toString retry)
      (toString expire)
      (toString minimum)
    ];
  };
}
