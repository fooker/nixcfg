let
  extensions = [
    # Add ipam extensions to lib
    (import ../../ipam.nix/lib)

    # Add our own extensions
    (self: super: {
      fn = import ./fn.nix self;
      dag = import ./dag.nix self;
      dns = import ./dns.nix self;

      types = super.types
        // self.fn.types
        // self.dag.types
        // self.dns.types;

      inherit (self.dns) parseDomain mkDomainAbsolute mkDomainRelative;
      inherit (self.dag) topoSort dagEntry;
    })
  ];

in
lib: lib.foldl (lib: lib.extend) lib extensions
