{ lib, ... }:

let
  ext = lib.makeExtensible (self:
    let
      callLibs = file: import file { inherit lib; ext = self; };
    in {
      fn = callLibs ./fn.nix;
      dag = callLibs ./dag.nix;
      dns = callLibs ./dns.nix;

      types = lib.types
        // self.fn.types
        // self.dag.types
        // self.dns.types;

      inherit (self.dns) domain;
  });
in {
  _module.args = {
    inherit ext;
  };
}
