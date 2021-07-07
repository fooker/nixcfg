{ lib, ... }:

with lib;

{
  types = {
    fnOf = retType: mkOptionType rec {
      name = "fnOf";
      description = "Function retuning a ${retType.description}";
      check = isFunction;
      merge = loc: defs: args:
        let
          defs' = map ({ file, value }: { inherit file; value = value args; }) defs;
        in
        (mergeDefinitions
          (loc ++ [ "{...}" ])
          retType
          defs'
        ).mergedValue;
      functor = (defaultFunctor name) // { wrapped = retType; };
    };
  };
}
