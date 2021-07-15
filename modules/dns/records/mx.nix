{ config, lib, ... }:

with lib;

{
  options = {
    preference = mkOption {
      type = types.ints.u16;
      default = 0;
      description = ''
        Specifies the preference given to this resource record among others at
        the same owner. Lower values are preferred.
      '';
    };

    exchange = mkOption {
      type = types.domain;
      description = ''
        A domain name which specifies a host willing to act as a mail exchange
        for the owner name.
      '';
    };
  };

  config = {
    data = with config; [
      (toString preference)
      exchange
    ];
  };
}
