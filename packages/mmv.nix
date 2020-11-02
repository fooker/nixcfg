{ rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  name = "mmv";

  src = builtins.fetchGit {
    url = "https://github.com/fooker/mmv.git";
    ref = "master";
  };

  cargoSha256 = "1vy6jidhwv14gf7zqll9fa1p3asin798zgavyn7rk9m2583p1bx4";
}
