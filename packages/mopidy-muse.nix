{ python3Packages, mopidy, ... }:

python3Packages.buildPythonApplication rec {
  pname = "mopidy-muse";
  version = "0.0.16";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "Mopidy-Muse";
    sha256 = "0dhqp6sra50iycdj73ffhns3l0nacymvnnzh2wsi8hmn35ym81h0";
  };

  propagatedBuildInputs = [ mopidy python3Packages.configobj ];

  doCheck = false;
}
