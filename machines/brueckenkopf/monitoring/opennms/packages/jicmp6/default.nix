{ stdenv
, fetchFromGitHub
, autoreconfHook
, jdk8_headless
}:

stdenv.mkDerivation rec {
  pname = "jicmp6";
  version = "2.0.4-1";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "0gyvvgm1zgn4r95k85ss55jgsil6yzhn39g1j3yawc52jnhsg2k9";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ jdk8_headless ];
}
