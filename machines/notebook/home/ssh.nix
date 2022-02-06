{ ... }:

{
  programs.ssh = {
    enable = true;

    controlMaster = "auto";
    controlPersist = "10m";

    forwardAgent = true;

    matchBlocks = {
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

      "nixos-builder" = {
        hostname = "172.23.200.35";
        proxyJump = "root@brueckenkopf.dev.open-desk.net";
        user = "root";
        identitiesOnly = true;
      };

      "paradeplatz" = {
        hostname = "172.23.200.34";
        proxyJump = "root@brueckenkopf.dev.open-desk.net";
        user = "root";
        identitiesOnly = true;
      };

      "br1" = {
        hostname = "192.168.254.3";
        proxyJump = "root@172.23.200.129";
        user = "root";
        identitiesOnly = true;
        extraOptions = {
          "KexAlgorithms" = "+diffie-hellman-group1-sha1";
          "Ciphers" = "+aes256-cbc";
          "HostKeyAlgorithms" = "+ssh-rsa";
        };
      };

      "br2" = {
        hostname = "192.168.254.4";
        proxyJump = "root@172.23.200.129";
        user = "root";
        identitiesOnly = true;
        extraOptions = {
          "KexAlgorithms" = "+diffie-hellman-group1-sha1";
          "Ciphers" = "+aes256-cbc";
          "HostKeyAlgorithms" = "+ssh-rsa";
        };
      };

      "br3" = {
        hostname = "192.168.254.5";
        proxyJump = "root@172.23.200.129";
        user = "root";
        identitiesOnly = true;
        extraOptions = {
          "KexAlgorithms" = "+diffie-hellman-group1-sha1";
          "Ciphers" = "+aes256-cbc";
          "HostKeyAlgorithms" = "+ssh-rsa";
        };
      };
    };

    extraConfig = ''
      VerifyHostKeyDNS yes
    '';
  };
}
