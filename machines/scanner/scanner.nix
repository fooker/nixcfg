{ config, lib, pkgs, path, inputs, ... }:

with lib;

let
  secrets = import ./secrets.nix;

  qd = pkgs.callPackage ../../packages/qd.nix { inherit inputs; };

  driver = "fujitsu";

  scanScript = pkgs.writeShellScript "scan" ''
    set -e -u -o pipefail

    # Scan the document
    ${qd}/bin/qd -v -v -p /mnt/spool push \
      ${pkgs.sane-frontends}/bin/scanadf \
        --device-name "$SCANBD_DEVICE" \
        --verbose \
        --output-file 'scan-%03d.ppm' \
        --resolution 300 \
        --mode 'Color' \
        --source 'ADF Duplex'
  '';

  uploadScript = pkgs.writeShellScript "upload" ''
    set -e -u -o pipefail
    shopt -s failglob

    for PPM in *.ppm; do
      ${pkgs.imagemagick}/bin/convert \
        "$PPM" \
        "''${PPM%.*}.png"
    done

    ${pkgs.img2pdf}/bin/img2pdf \
      --verbose \
      --output scan.pdf \
      *.png

      ${pkgs.openssh}/bin/scp \
        -i ${config.deployment.keys."scanner-sshkey".path} \
        ./scan.pdf \
        scanner@nas.dev.home.open-desk.net:"$QD_JOB_ID.pdf"

      ${pkgs.curl}/bin/curl \
        -v \
        -u ${secrets.paperless.upload.username}:${secrets.paperless.upload.password} \
        https://docs.home.open-desk.net//api/documents/post_document/ \
        -X POST \
        -F document=@scan.pdf
  '';

  scanbdConfigDir = pkgs.linkFarm "scanbd-conf" [
    {
      name = "saned.conf";
      path = pkgs.writeText "scanbd-conf-saned" ''
        127.0.0.1
        ::1
        172.23.200.128/25
        172.23.200.127/32
        fd79:300d:6056:100::/64
        fd79:300d:6056:ffff::0/128
      '';
    }

    {
      name = "dll.conf";
      path = pkgs.writeText "scanbd-conf-dll" ''
        ${driver}
      '';
    }

    {
      name = "${driver}.conf";
      path = "${pkgs.sane-backends}/etc/sane.d/${driver}.conf";
    }

    {
      name = "scripts/scan.script";
      path = scanScript;
    }
  ];

  saneConfigDir = pkgs.linkFarm "sane-conf" [
    {
      name = "saned.conf";
      path = pkgs.writeText "sane-conf-saned" ''
      '';
    }

    {
      name = "dll.conf";
      path = pkgs.writeText "sane-conf-dll" ''
        net
      '';
    }

    {
      name = "net.conf";
      path = pkgs.writeText "sane-conf-net" ''
        connect_timeout = 3
        localhost
      '';
    }
  ];

  scanbdConfig = pkgs.writeText "scanbd-conf-scanbd" ''
    global {
      user = scanner
      group = scanner

      pidfile = "/run/scanbd.pid"
      
      debug = false
      debug-level = 2

      saned = "${pkgs.sane-backends}/sbin/saned"
      saned_opt = {}
      saned_env = { "SANE_CONFIG_DIR=${scanbdConfigDir}" }

      scriptdir = ${scanbdConfigDir}/scripts

      timeout = 500

      environment {
        device = "SCANBD_DEVICE"
        action = "SCANBD_ACTION"
      }

      multiple_actions = true
    }

    device ${driver} {
      filter = "^${driver}.*"

      action scan {
        filter = "^scan.*"
        numerical-trigger {
                from-value = 1
                to-value   = 0
        }
        desc   = "Start Scan"
        script = "scan.script"
      }
    }
  '';

  scanbd = pkgs.scanbd.overrideAttrs (_: {
    postInstall = ''
      mkdir -p $out/share/dbus-1/system.d/
      sed 's/<policy user="saned">/<policy user="scanner">/' < integration/scanbd_dbus.conf > $out/share/dbus-1/system.d/scanbd.conf

      mkdir -p $out/share/dbus-1/system-services
      cp integration/systemd/de.kmux.scanbd.server.service $out/share/dbus-1/system-services
    '';
  });

in
{
  # Workaround to build on (currently) broken aarch64
  nixpkgs.overlays = [
    (_: super: rec {
      python38 = super.python38.override {
        packageOverrides = _: super: {
          pikepdf = super.pikepdf.overrideAttrs (_: {
            doCheck = false;
            doInstallCheck = false;
          });
        };
      };

      python38Packages = python38.pkgs;
    })
  ];


  # Allow scanning over network
  boot.kernelModules = [ "nf_conntrack_sane" ];

  # Define user for scanning
  users = {
    users.scanner = {
      uid = config.ids.uids.scanner;

      home = "/var/lib/scanner";
      createHome = true;

      group = "scanner";
    };
    groups.scanner = {
      gid = config.ids.gids.scanner;
    };
  };

  # Scanbd services
  systemd.services."scanbd" = {
    description = "Scanner button polling Service";

    environment = {
      "SANE_CONFIG_DIR" = scanbdConfigDir;
    };

    serviceConfig = {
      Type = "simple";

      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";

      ExecStart = "${scanbd}/bin/scanbd -f -c ${scanbdConfig}";
    };

    wantedBy = [ "multi-user.target" ];
    aliases = [ "dbus-de.kmux.scanbd.server.service" ];
  };

  systemd.services."scanbm@" = {
    description = "Scanner Service";
    requires = [ "scanbm.socket" ];

    environment = {
      "SANE_CONFIG_DIR" = scanbdConfigDir;
    };

    serviceConfig = {
      User = "scanner";
      Group = "scanner";

      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";

      ExecStart = "${scanbd}/bin/scanbm -c ${scanbdConfig}";
    };
  };

  systemd.sockets."scanbm" = {
    description = "Scanner Service";

    socketConfig = {
      ListenStream = 6566;
      Accept = "yes";
    };

    wantedBy = [ "sockets.target" ];
  };

  # Install dbus config for scanbd communication
  services.dbus.packages = [ scanbd ];

  # Install udev rules for scanner hardware
  # This makes the hardware accesible by the scanner group
  services.udev.packages = [ pkgs.sane-backends ];

  # Install scanner tools
  environment.systemPackages = [
    pkgs.sane-backends
  ];

  environment.variables = {
    "SANE_CONFIG_DIR" = toString saneConfigDir;
  };

  # Retry uploading regulary
  systemd.services."upload" = {
    description = "Upload scans for further processing";

    unitConfig = {
      RequiresMountsFor = "/mnt/spool";
    };

    serviceConfig = {
      Type = "simple";

      User = "scanner";
      Group = "scanner";

      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";

      ExecStart = "${qd}/bin/qd -v -v -p /mnt/spool daemon ${uploadScript}";
    };

    wantedBy = [ "multi-user.target" ];
  };

  # Add upload target to known hosts
  services.openssh.knownHosts = {
    "nas" = {
      hostNames = [ "nas.dev.home.open-desk.net" "172.23.200.130" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ58kj0PhHZThJ00tXLwNCFfK8o4RArFcNqtWfaXWto3";
    };
  };

  firewall.rules = dag: with dag; {
    inet.filter.input = {
      sane = between [ "established" ] [ "drop" ] [
        ''ip saddr { 172.23.200.128/25, 172.23.200.127/32 } tcp dport 6566 accept''
        ''ip6 saddr { fd79:300d:6056:100::/64, fd79:300d:6056:ffff::0/128 } tcp dport 6566 accept''
      ];
    };
  };

  deployment.keys = {
    "scanner-sshkey" = rec {
      keyFile = "${path}/secrets/id_scanner";
      destDir = "/etc/secrets/id_scanner";
      user = "scanner";
      group = "scanner";
    };
  };
}
