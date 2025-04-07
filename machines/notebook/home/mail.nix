{ pkgs, lib, ... }:

with lib;

{
  accounts.email = {
    maildirBasePath = ".cache/maildir";

    accounts = {
      "open-desk" = {
        primary = true;

        address = "fooker@open-desk.net";
        aliases = [
          "fooker@lab.sh"
          "root@open-desk.net"
        ];

        realName = "Dustin Frisch";

        gpg = {
          encryptByDefault = true;
          signByDefault = true;
          key = "3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE";
        };

        imap = {
          host = "mail.open-desk.net";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        smtp = {
          host = "mail.open-desk.net";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        userName = "fooker@open-desk.net";

        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };

      "gmail" = {
        address = "dustin.frisch@gmail.com";
        aliases = [ ];

        realName = "Dustin Frisch";

        gpg = {
          encryptByDefault = false;
          signByDefault = true;
          key = "3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE";
        };

        imap = {
          host = "imap.gmail.com";
          port = 993;
          tls.enable = true;
        };

        smtp = {
          host = "smtp.gmail.com";
          port = 465;
          tls.enable = true;
        };

        userName = "dustin.frisch@gmail.com";

        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };

      "maglab" = {
        address = "fooker@maglab.space";
        aliases = [
          "vorstand@maglab.space"
        ];

        realName = "Dustin Frisch";

        gpg = {
          encryptByDefault = false;
          signByDefault = true;
          key = "3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE";
        };

        imap = {
          host = "imap.open-mail.net";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        smtp = {
          host = "smtp.open-mail.net";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        userName = "fooker@maglab.space";

        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };

      "hs-fulda" = {
        address = "dustin.frisch@informatik.hs-fulda.de";
        aliases = [
          "dustin.frisch@cs.hs-fulda.de"
        ];

        realName = "Dustin Frisch";

        gpg = {
          encryptByDefault = false;
          signByDefault = true;
          key = "3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE";
        };

        imap = {
          host = "imap.hs-fulda.de";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        smtp = {
          host = "smtp.hs-fulda.de";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        userName = "fdai2856";

        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };

      "work" = {
        address = "dustin.frisch@hs-fulda.de";

        realName = "Dustin Frisch";

        gpg = {
          encryptByDefault = false;
          signByDefault = true;
          key = "3237CA7A1744B4DCE96B409FB4C3BF012D9B26BE";
        };

        imap = {
          host = "imap.hs-fulda.de";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        smtp = {
          host = "smtp.hs-fulda.de";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        userName = "fdhlb212";

        signature.showSignature = "append";
        signature.text = ''
          Digitale Dienste
          Hochschul-, Landes- und Stadtbibliothek Fulda

          Hochschule Fulda
          University of Applied Sciences
          Leipziger Str. 123
          36037 Fulda

          mailto:dustin.frisch@hs-fulda.de
          tel:+49-661-9640-9847
          https://hs-fulda.de/hlsb
        '';

        thunderbird = {
          enable = true;
          profiles = [ "default" ];
        };
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
      };
    };
  };
}
