{ runCommandNoCC
, fetchurl
, gnutar
}:

let
  version = "28.0.1";

  src = fetchurl {
    url = "https://vault.opennms.com/horizon/${version}/standalone/opennms-${version}.tar.gz";
    sha256 = "1b4kv5nz9slb6bcp5pxmaiiickwyzsrq3wmc4aaypq5m9palbr8z";
  };

in
runCommandNoCC "opennms-${version}"
{
  buildInputs = [ gnutar ];
  preferLocalBuild = true;
} ''
  mkdir -pv $out/opt/opennms
  tar -xzf ${src} -C $out/opt/opennms
''
