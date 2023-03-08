# Adjusted from https://gitlab.com/rycee/nur-expressions/blob/b34e2e548da574c7bd4da14d1779c95b62349a3a/lib/dag.nix (MIT)

# A generalization of Nixpkgs's `strings-with-deps.nix`.
#
# The main differences from the Nixpkgs version are
#
#  - not specific to strings, i.e., any payload is OK,
#
#  - the addition of the function `entryBefore` indicating a
#    "wanted by" relationship.

lib:

with lib;

{
  types = {
    dagOf = type: types.attrsOf (types.submodule {
      options = {
        data = mkOption {
          inherit type;
        };

        before = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };

        after = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
      };
    });
  };

  # Takes an attribute set containing entries built by
  # entryAnywhere, entryAfter, and entryBefore to a
  # topologically sorted list of entries.
  #
  # Internally this function uses the `toposort` function in
  # `<nixpkgs/lib/lists.nix>` and its value is accordingly.
  #
  # Specifically, the result on success is
  #
  #    { result = [{name = ?; data = ?;} …] }
  #
  # For example
  #
  #    nix-repl> topoSort {
  #                a = entryAnywhere "1";
  #                b = entryAfter ["a" "c"] "2";
  #                c = entryBefore ["d"] "3";
  #                d = entryBefore ["e"] "4";
  #                e = entryAnywhere "5";
  #              } == {
  #                result = [
  #                  { data = "1"; name = "a"; }
  #                  { data = "3"; name = "c"; }
  #                  { data = "2"; name = "b"; }
  #                  { data = "4"; name = "d"; }
  #                  { data = "5"; name = "e"; }
  #                ];
  #              }
  #    true
  #
  # And the result on error is
  #
  #    {
  #      cycle = [ {after = ?; name = ?; data = ?} … ];
  #      loops = [ {after = ?; name = ?; data = ?} … ];
  #    }
  #
  # For example
  #
  #    nix-repl> topoSort {
  #                a = entryAnywhere "1";
  #                b = entryAfter ["a" "c"] "2";
  #                c = entryAfter ["d"] "3";
  #                d = entryAfter ["b"] "4";
  #                e = entryAnywhere "5";
  #              } == {
  #                cycle = [
  #                  { after = ["a" "c"]; data = "2"; name = "b"; }
  #                  { after = ["d"]; data = "3"; name = "c"; }
  #                  { after = ["b"]; data = "4"; name = "d"; }
  #                ];
  #                loops = [
  #                  { after = ["a" "c"]; data = "2"; name = "b"; }
  #                ];
  #              } == {}
  #    true
  topoSort = dag:
    let
      dagBefore = dag: name:
        attrNames (
          filterAttrs (_: v: any (a: a == name) v.before) dag
        );
      normalizedDag =
        mapAttrs
          (name: value: {
            inherit name;
            inherit (value) data;
            after = value.after ++ dagBefore dag name;
          })
          dag;
      before = a: b: any (c: a.name == c) b.after;
      sorted = toposort before (attrValues normalizedDag);
    in
    if sorted ? result then
      { result = map (v: { inherit (v) name data; }) sorted.result; }
    else
      sorted;

  dagEntry = {
    anywhere = data: {
      inherit data;
      before = [ ];
      after = [ ];
    };

    between = after: before: data: {
      inherit data before after;
    };

    after = after: data: {
      inherit data after;
      before = [ ];
    };

    before = before: data: {
      inherit data before;
      after = [ ];
    };
  };
}
