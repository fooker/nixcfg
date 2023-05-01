self: super: {
  fn = import ./fn.nix self;
  dag = import ./dag.nix self;

  types = super.types
    // self.fn.types
    // self.dag.types;

  inherit (self.dag) topoSort dagEntry;
}
