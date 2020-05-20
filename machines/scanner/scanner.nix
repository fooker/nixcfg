{ config, lib, pkgs, ... }:

with lib;

let
  driver = "fujitsu";

  scanScript = pkgs.writeShellScript "script" ''
    set -e -u -o pipefail

    # Generate a document ID
    DID="$(${pkgs.utillinux}/bin/uuidgen)"

    TARGET="/mnt/tmp/$DID"

    # Generate the target document directory
    mkdir -p "$TARGET"

    # Scan the document
    ${pkgs.sane-frontends}/bin/scanadf \
      --device-name "$SCANBD_DEVICE" \
      --verbose \
      --output-file "$TARGET/scan-%03d.ppm" \
      --resolution 300 \
      --mode 'Color' \
      --source 'ADF Duplex'
    
    # Move to spool
    mkdir -p /mnt/spool
    mv $TARGET /mnt/spool/$DID

    # Trigger upload
    ${pkgs.systemd}/bin/systemctl start \
      --no-block \
      upload
  '';

  uploadScript = pkgs.writeShellScript "upload" ''
    set -e -u -o pipefail

    cd /mnt/spool
    for DID in *; do (cd "$DID"
      for PPM in *.ppm; do
        ${pkgs.imagemagick}/bin/convert "$PPM" "$(basename "$PPM").jpg"
      done

      ${pkgs.img2pdf}/bin/img2pdf \
        --verbose \
        --output scan.pdf \
        *.jpg

        scp ./scan.pdf scanner@adacta.open-desk.net:"$DID.pdf"

        rm "$(pwd)" \
          --verbose \
          --force \
          --recursive
    ); done
  '';

  scanbdConfigDir = pkgs.linkFarm "scanbd-conf" [
    {
      name = "saned.conf";
      path = pkgs.writeText "scanbd-conf-saned" ''
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

  scanbd = pkgs.scanbd.overrideAttrs (super: {
    postInstall = ''
      mkdir -p $out/share/dbus-1/system.d/
      sed 's/<policy user="saned">/<policy user="scanner">/' < integration/scanbd_dbus.conf > $out/share/dbus-1/system.d/scanbd.conf

      mkdir -p $out/share/dbus-1/system-services
      cp integration/systemd/de.kmux.scanbd.server.service $out/share/dbus-1/system-services
    '';
  });

in {
  # Allow scanning over network
  networking.firewall.connectionTrackingModules = [ "sane" ];

  # Define user for scanning
  users = {
    users.scanner = {
      uid = config.ids.uids.scanner;
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
      StandardOutput = "syslog";
      StandardError = "syslog";

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
      StandardOutput = "syslog";
      StandardError = "syslog";

      ExecStart = "${scanbd}/bin/scanbm -c ${scanbdConfig}";
    };
  };

  systemd.sockets."scanbm" = {
    description = "Scanner Service";

    socketConfig = {
      ListenStream = 6566;
      Accept = "yes";
      MaxConnections = 1;
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
      RequiresMountsFor = "/mnt";
    };

    serviceConfig = {
      Type = "oneshot";

      User = "scanner";
      Group = "scanner";

      StandardInput = "null";
      StandardOutput = "syslog";
      StandardError = "syslog";

      ExecStart = "${uploadScript}";
    };
  };

  systemd.timers."upload" = {
    description = "Upload scans for further processing";
  };
}
