{ stdenvNoCC
, fetchzip
, makeWrapper
, nodejs-slim
, coreutils
, which
, lib
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "opensearch-dashboard";
  version = "2.7.0";

  src = fetchzip {
    url = "https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/${version}/opensearch-dashboards-${version}-linux-x64.tar.gz";
    hash = "sha256-DfjAUzBXMoUggQ9xkSs8xlo1vHHmUScIo9lpM3PpiNU=";
  };

  patches = [
    ./extend-nodejs-version.patch
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,libexec/opensearch-dashboards}

    mv * $out/libexec/opensearch-dashboards/
    rm -r $out/libexec/opensearch-dashboards/node
    rm -r $out/libexec/opensearch-dashboards/data

    rm -r $out/libexec/opensearch-dashboards/plugins/securityDashboards

    makeWrapper $out/libexec/opensearch-dashboards/bin/opensearch-dashboards $out/bin/opensearch-dashboards \
       --prefix PATH : "${lib.makeBinPath [ nodejs-slim coreutils which ]}"
  '';
}
