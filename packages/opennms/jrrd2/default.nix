{ stdenv
, buildMaven
, fetchFromGitHub
, jdk8_headless
, maven
, cmake
, pkg-config
, rrdtool
}:

let
  m2 = buildMaven ./maven-deps.json;
in
stdenv.mkDerivation rec {
  pname = "jrrd2";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = pname;
    rev = version;
    sha256 = "05ax3xxlzgby23ll1anxa3qy1jc23i1l8swdyzgvink18qyb2rky";
  };

  patches = [
    ./maven-deps.patch
  ];

  nativeBuildInputs = [ jdk8_headless maven cmake pkg-config ];
  buildInputs = [ rrdtool ];

  dontUseCmakeConfigure = true;
  dontConfigure = true;

  buildPhase = ''
    (
      cd java
      mvn --offline --settings ${m2.settings} clean compile
    )

    (
      cd jni
      cmake .
      make
    )

    (
      cd java
      mvn --offline --settings ${m2.settings} package -Dmaven.test.skip=true -Dmaven.site.skip=true -Dmaven.javadoc.skip=true
      cp -v target/jrrd2-api-*.jar ../dist/
    )
  '';

  installPhase = ''
    mkdir $out
    cp -v -r dist/* $out/
  '';
}
