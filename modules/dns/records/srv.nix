{ config, lib, ... }:

with lib;

{
  options = {
    priority = mkOption {
      type = types.ints.u16;
      default = 0;
      description = ''
        The priority of the host specified in <option>target</option>.
        Clients will always contact the target with the lowest priority it can
        reach.
      '';
    };

    weight = mkOption {
      type = types.ints.u16;
      default = 0;
      description = ''
        Specifies a relative weight for entries with the same priority.
        Larger weights are given a proportionately higher probability of being
        selected.
        In the presence of records containing weights greater than 0, records
        with weight 0 should have a very small chance of being selected.
      '';
    };

    port = mkOption {
      type = types.ints.u16;
      description = ''
        The port to be used for contacting the <option>target</option>.
      '';
    };

    target = mkOption {
      type = types.domain;
      description = ''
        The domain name of the target host.
        A target of <literal>.</literal> means that the service is decidedly not
        available at this domain.
      '';
    };
  };

  config = {
    data = with config; [
      (toString priority)
      (toString weight)
      (toString port)
      target
    ];
  };
}
