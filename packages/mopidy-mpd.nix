{ pkgs, python3Packages, mopidy, ... }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-mpd";
  version = "3.0.0";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "Mopidy-MPD";
    sha256 = "0prjli4352521igcsfcgmk97jmzgbfy4ik8hnli37wgvv252wiac";
  };

  propagatedBuildInputs = [ mopidy ];

  doCheck = false;
  pythonImportsCheck = [ "mopidy_mpd" ];
}
