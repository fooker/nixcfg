{ lib, pkgs, sources, ... }@args:

with lib;

let
  ipinfo = pkgs.rustPlatform.buildRustPackage rec {
    pname = "ipinfo";
    version = "master";

    src = sources.ipinfo;

    cargoSha256 = "01igp9rymmhqfp5ys2cv9pay0w81jd3957bflvvv5ccyic5r103p";

    meta = with pkgs.stdenv.lib; {
      description = "IP address info dumper";
      homepage = "https://github.com/fooker/ipinfo";
      license = licenses.wtfpl;
      platforms = platforms.all;
    };
  };

in input: importJSON (pkgs.runCommand "ipinfo-json" {} ''
    ${ipinfo}/bin/ipinfo -j "${input}" > $out
  '')
