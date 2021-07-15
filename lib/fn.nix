lib:

with lib;

{
  types = {
    fnOf = type: mkOptionType rec {
      name = "fnOf";
      description = "Function retuning a ${type.description}";
      check = isFunction;
      merge = loc: defs: args:
        let
          defs' = map ({ file, value }: { inherit file; value = value args; }) defs;
        in
        (mergeDefinitions
          (loc ++ [ "{...}" ])
          type
          defs'
        ).mergedValue;
      functor = (defaultFunctor name) // { wrapped = type; };
    };
  };
}
