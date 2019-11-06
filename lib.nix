rec {
  /* Returns the path for a machine
  */
  path = machine:
    ./machines + "/${machine}";

  /* Read the machine configuration from machine.nix in the machines directory
  */
  config = machine:
    import ((path machine) + /machine.nix);


  /* Build the SSH target for the given machine name
  */
  target = machine:
    let cfg = config machine;
    in "${cfg.target.user}@${cfg.target.host}";
}
