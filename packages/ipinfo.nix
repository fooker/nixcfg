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

  cargoSha256 = "06gybhg805s2wq72jk428c4hn7qchk8hx99yh86hf09a496zndh1";

  meta = with stdenv.lib; {
    description = "IP address info dumper";
    homepage = "https://github.com/fooker/ipinfo";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
