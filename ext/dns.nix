{ lib, ... }:

with lib;

rec {
  domain =
    let
      check = labels:
        assert isList labels;
        assert all isString labels;
        assert all (label: stringLength label > 0) labels;
        assert all (label: stringLength label <= 63) labels;
        labels;

      split = s:
        if s == "" then [ ]
        else reverseList (splitString "." s);

      mkDomain = { labels, absolute }: setType "domain" (rec {
        inherit labels;

        isAbsolute = absolute;
        isRelative = !absolute;

        # Resolve a domain relative to this one
        resolve = sub:
          assert isType "domain" sub;
          if sub.isRelative
          then
            mkDomain
              {
                labels = (labels ++ sub.labels);
                inherit absolute;
              }
          else sub;

        # Get the parent of this domain name
        parent =
          assert labels != [ ];
          mkDomain {
            labels = (init labels);
            inherit absolute;
          };

        # Create DNS records in a zone denoted by this domain name
        mkRecords = setAttrByPath labels;

        toSimpleString = concatStringsSep "." (reverseList labels);
        toString =
          if absolute
          then "${ toSimpleString }."
          else toSimpleString;

        __toString = self: self.toString;
      });

    in
    rec {
      absolute = domain:
        let
          labels =
            if isString domain
            then split (removeSuffix "." domain)
            else domain;
        in
        mkDomain {
          labels = check labels;
          absolute = true;
        };

      relative = domain:
        let
          labels =
            if isString domain
            then split domain
            else domain;
        in
        mkDomain {
          labels = check labels;
          absolute = false;
        };

      parse = domain:
        assert isString domain;
        if hasSuffix "." domain
        then absolute domain
        else relative domain;

      root = absolute [ ];
    };

  types = {
    # Like types.uniq but merges equal definitions
    equi = type: mkOptionType rec {
      name = "equi";
      inherit (type) description check;
      merge = mergeEqualOption;
      emptyValue = type.emptyValue;
      getSubOptions = type.getSubOptions;
      getSubModules = type.getSubModules;
      substSubModules = m: equi (type.substSubModules m);
      functor = (defaultFunctor name) // { wrapped = type; };
    };

    domain =
      let
        type = mkOptionType {
          name = "domain";
          description = "domain name";
          check = isType "domain";
          merge = mergeOneOption;
        };

      in
      (lib.types.coercedTo lib.types.str domain.parse type) // {
        absolute = lib.types.coercedTo lib.types.str domain.parse (type // {
          description = "absolute ${type.description}";
          check = x: type.check x && x.isAbsolute;
        });

        relative = lib.types.coercedTo lib.types.str domain.parse (type // {
          description = "relative ${type.description}";
          check = x: type.check x && x.isRelative;
        });
      };
  };
}
