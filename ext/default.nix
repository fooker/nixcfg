{ lib, ... }:

let
  ext = lib.makeExtensible (self:
    let
      callLibs = file: import file { inherit lib; ext = self; };
    in with self; {
      fn = callLibs ./fn.nix;
      dag = callLibs ./dag.nix;
    }
  );
in {
  _module.args = {
    inherit ext;
  };
}
