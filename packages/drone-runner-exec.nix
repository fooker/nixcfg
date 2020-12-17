{ stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "drone-runner-exec";
  version = "2020-04-19";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-exec";
    rev = "c0a612ef2bdfdc6d261dfbbbb005c887a0c3668d";
    sha256 = "06smi9gddjngcy01ah2bjw2ri03qlwpfhpr6mg868qxrj310jhni";
  };

  vendorSha256 = "1k16xg17my0zqc4w03v9y3v4780pg9mnkvaibw3191aimi02x5na";

  meta = with stdenv.lib; {
    description = "Drone pipeline runner that executes builds directly on the host machine";
    homepage = "https://github.com/drone-runners/drone-runner-exec";
    
    # https://polyformproject.org/licenses/small-business/1.0.0/
    license = licenses.unfree;
  };
}