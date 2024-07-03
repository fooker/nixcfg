{ stdenv
, fetchFromGitHub
, jemalloc
, libuuid
, curl
, systemd
, pkg-config
, ...
}:

stdenv.mkDerivation rec {
  pname = "keydb";
  version = "6.3.4";

  src = fetchFromGitHub {
    owner = "Snapchat";
    repo = "KeyDB";
    rev = "v${version}";
    sha256 = "sha256-j6qgK6P3Fv+b6k9jwKQ5zW7XLkKbXXcmHKBCQYvwEIU=";
  };

  patches = [
    ./001-makefile-os-detection.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    jemalloc
    libuuid
    curl
    systemd
  ];

  BUILD_TLS = "yes";
  USE_SYSTEMD = "yes";

  installFlags = [
    "PREFIX=$(out)"
  ];
}
