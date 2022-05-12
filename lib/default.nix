self: super: {
  fn = import ./fn.nix self;
  dag = import ./dag.nix self;
  dns = import ./dns.nix self;

  types = super.types
    // self.fn.types
    // self.dag.types
    // self.dns.types;

  inherit (self.dns) parseDomain mkDomainAbsolute mkDomainRelative;
  inherit (self.dag) topoSort dagEntry;
}
