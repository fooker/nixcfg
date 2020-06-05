{ pkgs, python3Packages, ... }:

python3Packages.buildPythonApplication rec {
  pname = "websocket_client";
  version = "0.57.0";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "websocket_client";
    sha256 = "04108mpz6yjcvjwinmkg6mrn6pwf4ghcka7jh6hsd4hndlfvjdfp";
  };

  propagatedBuildInputs = [ python3Packages.six ];

  doCheck = false;
}
