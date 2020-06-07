{ stdenv, rustPlatform, sources, ... }:

rustPlatform.buildRustPackage {
  pname = "ipinfo";
  version = "master";

  src = sources.ipinfo;

  cargoSha256 = "01igp9rymmhqfp5ys2cv9pay0w81jd3957bflvvv5ccyic5r103p";

  meta = with stdenv.lib; {
    description = "IP address info dumper";
    homepage = "https://github.com/fooker/ipinfo";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
