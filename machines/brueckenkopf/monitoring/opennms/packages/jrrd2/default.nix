{ stdenv
, fetchFromGitHub
, jdk8_headless
, maven
, cmake
, pkg-config
, rrdtool
}:

stdenv.mkDerivation rec {
  pname = "jrrd2";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = pname;
    rev = version;
    sha256 = "05ax3xxlzgby23ll1anxa3qy1jc23i1l8swdyzgvink18qyb2rky";
  };

  nativeBuildInputs = [ jdk8_headless maven cmake pkg-config ];
  buildInputs = [ rrdtool ];

  dontUseCmakeConfigure = true;
  dontConfigure = true;

  buildPhase = ''
    (
      cd java
      mvn clean compile -Dmaven.repo.local=/tmp/m2
    )

    (
      cd jni
      cmake .
      make
    )

    (
      cd java
      mvn package -DskipTests -Dmaven.repo.local=/tmp/m2
      cp -v target/jrrd2-api-*.jar ../dist/
    )
  '';

  installPhase = ''
    mkdir $out
    cp -v -r dist/* $out/
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  outputHash = "155hajyx3fa17j4xn38kq52291sliakpim006jzz11qg4px3p7d1";
}