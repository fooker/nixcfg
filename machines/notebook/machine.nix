{
  target = {
    host = "127.0.0.1";
    user = "root";
  };

  tags = [ "prod" ];

  system = "x86_64-linux";

  deployment.allowLocalDeployment = true;

  stateVersion = "20.03";
}
