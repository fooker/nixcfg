{ rustPlatform, ... }:

rustPlatform.buildRustPackage rec {
  name = "qd";

  src = builtins.fetchGit {
    url = "https://github.com/fooker/qd.git";
    ref = "master";
  };

  cargoSha256 = "1hakklx7yjkcmmlig5whdhz9xx7lic69mw5n3xlqk7wx3fwaby5x";
}
