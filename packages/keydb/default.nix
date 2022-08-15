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
  version = "6.3.1";

  src = fetchFromGitHub {
    owner = "Snapchat";
    repo = "KeyDB";
    rev = "v${version}";
    sha256 = "sha256-00Dx6GRAXVpJUXhu4kjsVCEsoN615vhGvc7+gViERqI=";
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
