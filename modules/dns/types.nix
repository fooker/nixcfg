{ lib, ... }:

with lib;

let
  # Builder for record type options
  mkRecordOption = { type, singleton }: mkOption {
    type = if singleton
      then type
      else types.either type (types.listOf type);
    apply = if singleton
      then id
      else toList;
  };

in {
  # A simple record type containing a single value
  mkValueRecord = rtype: { type, singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.coercedTo type
      (value: { inherit value; })
      (types.submodule ({ config, ... }: {
        imports = [ ./record.nix ];
        options = {
          value = mkOption {
            inherit type;
            description = "The value of the record";
          };
        };
        config = {
          type = rtype;
          data = [ config.value ];
        };
      }));
  };

  # A record type containing whereas the data is defined by a module
  mkModuleRecord = rtype: mod: { singleton ? false }: mkRecordOption {
    inherit singleton;

    type = types.submodule {
      imports = [ ./record.nix mod ];
      config = {
        type = rtype;
      };
    };
  };
}