{ config, options, lib, ext, pkgs, nodes, ... }@args:

with lib;
with ext;

let
  record = (import ./record.nix args);

  # Match every name that is all-upercase
  isRecord = name: (builtins.match "[A-Z]+" name) != null;
  
  # Coerces an attrset to a zone submodule by splitting the attrset into three parts:
  # - the well-known attributes of the zone like `ttl`
  # - the resource records of this zone (all uppercase entries)
  # - all (virtual) sub-zones defined in this zone (everything else)
  coerceZone = attrs: let
    # Get the well-known attributes if they exists in the attrset
    known = getAttrs
      (filter
        (name: hasAttr name attrs)
        [ "ttl" ])
      attrs;
    
    # Partititon all attr names that are not well-know by being a record or not
    partitioned = partition
      isRecord
      (filter
        # Filter for everything that is not well-known
        (name: !(hasAttr name known))
        (attrNames attrs));
  in {
    records = getAttrs partitioned.right attrs;
    zones = getAttrs partitioned.wrong attrs;
  } // known;

  # Option type for zone definitions - similar to types.coercedTo but checking specific for
  # being a zone by looking zone specific records
  coercedZoneSubmodule = mod: mkOptionType rec {
    name = "coercedZoneSubmodule";
    description = "${mod.description} or ${types.attrs.description} convertible to it";
    
    check = x: mod.check x || (types.attrs.check x && mod.check (coerceZone x));
    
    merge = loc: defs:
      let
        coerceVal = val:
          if hasAttr "records" val || hasAttr "zones" val then val
          else coerceZone val;
      in mod.merge loc (map (def: def // { value = coerceVal def.value; }) defs);
    
    emptyValue = mod.emptyValue;
    getSubOptions = mod.getSubOptions;
    getSubModules = mod.getSubModules;

    substSubModules = m: coercedZoneSubmodule (mod.substSubModules m);
    
    typeMerge = t1: t2: null;
    
    functor = (defaultFunctor name) // { wrapped = mod; };
  };

  # Recursive zone type definition as used to configure DNS records
  zone = level:
    coercedZoneSubmodule (types.submodule {
      options = {
        ttl = mkOption {
          type = types.nullOr types.int;
          description = "The default TTL for all records in this zone";
          default = null;
        };

        records = mkOption {
          type = types.submodule ({ config, options, ... }: {
            imports = [ ./records ];
            options = {
              defined = mkOption {
                type = types.listOf types.str;
                description = "The list of defined record types";
                readOnly = true;
                internal = true;
              };
            };
            config = {
              defined = filter
                (name: isRecord name && options.${ name }.isDefined)
                (attrNames config);

              _module.args = { inherit ext record; };
            };
          });
          description = "Records of this zone";
          default = {};
        };
      } // optionalAttrs (level <= 127) {
        zones = mkOption {
          type = types.attrsOf (zone (level + 1));
          default = {};
        };
      };
    });

in {
  imports = [
    ./host.nix
  ];

  options.dns = {
    zones = mkOption {
      type = zone 0;
      description = "The DNS tree";
      default = {};
    };

    defaultTTL = mkOption {
      type = types.int;
      description = "The default TTL for all records";
      default = 3600;
    };

    global = mkOption {
      type = zone 0;
      description = "The global DNS tree";
      internal = true;
      readOnly = true;
    };

    zoneList = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.domain.absolute;
            readOnly = true;
            description = "The domain name of the zone";
          };

          records = mkOption {
            type = types.listOf (types.submodule {
              imports = [ record.module ];
              options = {
                domain = mkOption {
                  type = types.domain;
                  readOnly = true;
                  description = "The domain name of the record";
                };
              };
            });
            readOnly = true;
            description = "The records in the zone";
          };
        };
      });
      description = "The internal representation of the zones";
      internal = true;
      readOnly = true;
    };
  };

  config.dns = {
    # Build global DNS tree by merging the local tree from all nodes
    global = let
      cleanupRecord = def: removeAttrs def [ "data" ];

      walk = cfg: path: {
        # Use all defined records while stripping out the data element as it is re-created from the definition
        records = mapAttrs
          (type: record: if isList record
            then map cleanupRecord record
            else cleanupRecord record)
          (getAttrs cfg.records.defined cfg.records);
        
        # Recurs into all defined sub-zones
        zones = mapAttrs (name: zone: walk zone (path ++ [name])) cfg.zones;
      };
    in mkMerge (map
      (node: walk node.config.dns.zones [])
      (attrValues nodes));

    # Build the zone list from the zones. This is an list where each element is
    # just the zone name and a list of records in the zone.
    zoneList = let
      walk = { domain, zone, ttl, config }: let
        # If this domain has a SOA record, we found a new (sub) zone
        zone' = if elem "SOA" config.records.defined then domain else zone;

        # If the domain has defined a TTL we use it as default for all records and sub-zones
        ttl' = if config.ttl != null then config.ttl else ttl;

        # Build the resulting record type from a record in a zone
        mkRecord = record: {
          zone = zone';
          record = {
            inherit domain;
            inherit (record) class type data;

            ttl = if record.ttl != null then record.ttl else ttl';
          };
        };

        # Build the list of records in the current domain
        curr = concatMap
          (record: if isList record
            then map mkRecord record
            else singleton (mkRecord record))
          (attrVals config.records.defined config.records);

        # Recurse into all sub-domain
        next = concatLists (
          mapAttrsToList
            (name: value: walk {
              domain = domain.resolve (ext.domain.relative name);
              zone = zone';
              ttl = ttl';
              config = value;
            })
            config.zones);

      in curr ++ next;

      # Walk the tree and collect all records
      collected = walk {
        domain = ext.domain.root;
        zone = null;
        ttl = config.dns.defaultTTL;
        config = config.dns.global;
      };

      # Group the collected record by zone they are defined in
      # [ { zone, record } ... ] -> [ { zone, records = [ ... ]} ... ]
      grouped = attrValues (groupBy'
        (group: entry: {
          name = entry.zone;
          records = group.records ++ [ entry.record ];
        })
        { records = []; }
        (entry: toString entry.zone)
        collected);

    in grouped;
  };
}