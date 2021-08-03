{ stdenv
, fetchFromGitHub
, autoreconfHook
, postgresql
}:

stdenv.mkDerivation rec {
  pname = "iplike";
  version = "2.2.0-1";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "0lr96ck5x0bvknknw8c99bw827a994rqpbcpvmky239ap8hsmyjr";
    fetchSubmodules = true;
  };

  configureFlags = [ "PG_PLUGINDIR=$(out)/lib" ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ postgresql ];
}
