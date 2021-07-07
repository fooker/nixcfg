args @ { python3Packages
, mopidy
, websocket_client ? (args.python3Packages.callPackage ./websocket_client.nix { })
, ...
}:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-jellyfin";
  version = "0.8.0";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "Mopidy-Jellyfin";
    sha256 = "1mpac2yzb0sli5kjfdpc348z8k1ys976bjy430idnm5jldy268ix";
  };

  propagatedBuildInputs = [
    mopidy
    websocket_client
    python3Packages.unidecode
  ];

  doCheck = false;
  pythonImportsCheck = [ "mopidy_jellyfin" ];
}
