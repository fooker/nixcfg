{ stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "drone-runner-docker";
  version = "2020-11-20";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-docker";
    rev = "00b690ce8c9aa020b816bc47dae3be9fdef89294";
    sha256 = "1l76r3sqk21jv380123yv72nnk7ghim54kiplbbskc64mvjv5d14";
  };

  vendorSha256 = "15lpdliqz129yq5zgzjvndwdxngxa96g0ska4zkny7ycb3vwq0xm";

  meta = with stdenv.lib; {
    description = "Drone pipeline runner that executes builds inside Docker containers";
    homepage = "https://github.com/drone-runners/drone-runner-docker";
    
    # https://polyformproject.org/licenses/small-business/1.0.0/
    license = licenses.unfree;
  };
}