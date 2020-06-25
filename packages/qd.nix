{ rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  name = "qd";

  src = builtins.fetchGit {
    url = "https://github.com/fooker/qd.git";
    ref = "master";
  };

  cargoSha256 = "1mp7hzxi1dx2mirhb1bbi5maxyz5azvdd1xi9sr1z3ap4gpqjpgm";
}
