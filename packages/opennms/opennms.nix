{ runCommandNoCC
, fetchurl
, gnutar
}:

let
  version = "28.1.1";

  pkg = { name, hash, strip ? 0 }:
    let
      src = fetchurl {
        url = "https://vault.opennms.com/horizon/${version}/standalone/${name}-${version}.tar.gz";
        inherit hash;
      };
    in
    runCommandNoCC "${name}-${version}"
      {
        buildInputs = [ gnutar ];
        preferLocalBuild = true;
      } ''
      mkdir -pv $out/opt/${name}
      tar -xzf ${src} -C $out/opt/${name} --strip-components=${toString strip}
    '';

in
{
  horizon = pkg {
    name = "opennms";
    hash = "sha256-s5+6OrV73kwclFa4oxn3NsSxWfwW5cPsaXjNVRPqo/s=";
  };

  minion = pkg {
    name = "minion";
    hash = "sha256-ut5k7ChwozA/eoroB5B+EAMXkIoD81ruRdx8GhvTziM=";
    strip = 1;
  };
}
