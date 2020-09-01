{ stdenv, rustPlatform, fetchFromGitHub, ... }:

rustPlatform.buildRustPackage {
  pname = "ipinfo";
  version = "master";

  src = fetchFromGitHub {
    owner = "fooker";
    repo = "ipinfo";
    rev = "master";
    sha256 = "0071d926bbk7fx6n77ig70vifi16xylyhr3j382ryvrhganzgknd";
  };

  cargoSha256 = "01igp9rymmhqfp5ys2cv9pay0w81jd3957bflvvv5ccyic5r103p";

  meta = with stdenv.lib; {
    description = "IP address info dumper";
    homepage = "https://github.com/fooker/ipinfo";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
