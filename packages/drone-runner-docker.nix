{ lib
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
    hash = "sha256-JLSy5a7EsKnXojdOUmqE70xrxdl+iADQ2DKIifXI5tA=";
  };

  vendorHash = "sha256-tQPM91jMH2/nJ2pq8ExS/dneeLNb/vcL9kmEjyNtl5Y=";

  meta = with lib; {
    description = "Drone pipeline runner that executes builds inside Docker containers";
    homepage = "https://github.com/drone-runners/drone-runner-docker";

    # https://polyformproject.org/licenses/small-business/1.0.0/
    license = licenses.unfree;
  };
}
