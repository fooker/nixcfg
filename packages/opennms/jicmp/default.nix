{ stdenv
, fetchFromGitHub
, autoreconfHook
, jdk8_headless
}:

stdenv.mkDerivation rec {
  pname = "jicmp";
  version = "2.0.5-1";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "0b74s4nigd1kl9g4crjn7vlddsg6sdprmx69fg9jik9cqzvxn49a";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ jdk8_headless ];
}
