{ network, ... }:

{
  programs.ssh = {
    enable = true;

    controlMaster = "auto";
    controlPersist = "10m";

    forwardAgent = true;

    matchBlocks =
      let
        mkManagementJumpDevice = name: config: {
          "${name}" = {
            hostname = toString network.devices."${name}".interfaces."mngt".address.ipv4.address;
            proxyJump = "root@${toString network.devices."router".interfaces."priv".address.ipv4.address}";
            user = "root";
            identitiesOnly = true;
          } // config;
        };

        ciscoConfig = {
          extraOptions = {
            "KexAlgorithms" = "+diffie-hellman-group1-sha1";
            "Ciphers" = "+aes256-cbc";
            "HostKeyAlgorithms" = "+ssh-rsa";
          };
        };
      in
      {
        "opennms" = {
          hostname = "127.0.0.1";
          port = 8101;
          user = "admin";
          checkHostIP = false;
          extraOptions = {
            "StrictHostKeyChecking" = "no";
            "NoHostAuthenticationForLocalhost" = "yes";
            "SetEnv" = "TERM=xterm";
          };
        };

        "10.32.47.1??" = {
          proxyJump = "root@10.32.47.10";
          identitiesOnly = true;
        };
      }
      // (mkManagementJumpDevice "br1" ciscoConfig)
      // (mkManagementJumpDevice "br2" ciscoConfig)
      // (mkManagementJumpDevice "br3" ciscoConfig)
      // (mkManagementJumpDevice "ap-downstairs" { })
      // (mkManagementJumpDevice "ap-upstairs" { })
    ;

    extraConfig = ''
      VerifyHostKeyDNS yes
    '';
  };
}
