{ lib, ... }:

with lib;

rec {
  domain = let
    check = labels:
      assert isList labels;
      assert all (label: isString label) labels;
      assert all (label: stringLength label > 0) labels;
      assert all (label: stringLength label <= 63) labels;
      labels;
    
    split = s:
      if s == "" then []
      else reverseList (splitString "." s);

    mkDomain = { labels, absolute }: setType "domain" (rec {
      inherit labels;

      isAbsolute = absolute;
      isRelative = !absolute;

      resolve = sub:
        assert isType "domain" sub;
        if sub.isRelative
          then mkDomain {
            labels = (labels ++ sub.labels);
            inherit absolute;
          }
          else sub;

      parent =
        assert labels != [];
        mkDomain {
          labels = (init labels);
          inherit absolute;
        };

      mkZone = setAttrByPath labels;

      toSimpleString = concatStringsSep "." (reverseList labels);
      toString = if absolute
        then "${ toSimpleString }."
        else toSimpleString;
      
      __toString = self: self.toString;
    });

  in rec {
    absolute = domain: let
      labels = if isString domain
        then split (removeSuffix "." domain)
        else domain;
    in mkDomain {
      labels = check labels;
      absolute = true;
    };
    
    relative = domain: let
      labels = if isString domain
        then split domain
        else domain;
    in mkDomain {
      labels = check labels;
      absolute = false;
    };

    parse = domain: 
      assert isString domain;
      if hasSuffix "." domain
        then absolute domain
        else relative domain;
    
    root = absolute [];
  };

  types = {
    # Like types.uniq but merges equal definitions
    equi = elemType: mkOptionType rec {
      name = "equi";
      inherit (elemType) description check;
      merge = mergeEqualOption;
      emptyValue = elemType.emptyValue;
      getSubOptions = elemType.getSubOptions;
      getSubModules = elemType.getSubModules;
      substSubModules = m: equi (elemType.substSubModules m);
      functor = (defaultFunctor name) // { wrapped = elemType; };
    };

    domain = let
      type = mkOptionType {
        name = "domain";
        description = "domain name";
        check = isType "domain";
        merge = mergeOneOption;
      };

    in (lib.types.coercedTo lib.types.str domain.parse type) // {
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