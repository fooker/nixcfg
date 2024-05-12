{ writeScript
, bash
, pixiecore
, retry
, curl

  # nixpkgs for the installer image
, pkgs
, lib

  # The node to build installer for
, node

, ...
}:

with lib;

let
  installer = pkgs.nixos [
    (
      { modulesPath
      , lib
      , ...
      }:
      {
        imports = [
          "${modulesPath}/installer/netboot/netboot-minimal.nix"
        ];

        services.getty.autologinUser = lib.mkForce "root";

        networking.hostName = "installer-${node.config.networking.hostName}";

        boot.postBootCommands = ''
          for x in $(cat /proc/cmdline); do
            case "$x"; in
              installer.image=*)
                IMAGE="''${x#installer.image=}"
                ;;
              installer.device=*)
                DEVICE="''${x#installer.device=}"
                ;;
            esac
          done

          ${retry}/bin/retry \
            --times 10 \
            --delay 15 \
            -- ${curl}/bin/curl "$IMAGE" --output "$DEVICE"
        '';

        system.stateVersion = node.config.system.nixos.release;
      }
    )
  ];

in
writeScript "pxe-installer" ''
  #!${bash}/bin/bash

  set -eu -o pipefail

  ${pixiecore}/bin/pixiecore boot \
    "${installer.config.system.build.kernel}/bzImage" \
    "${installer.config.system.build.netbootRamdisk}/initrd" \
    --cmdline='${concatStringsSep " " [
      "init=${installer.config.system.build.toplevel}/init"
      "loglevel=4"
      "console=tty0"
      "console=ttyS1,115200n8"
      "installer.image={{ ID \"${node.config.system.build.diskoImages}/main.raw\" }}"
      "installer.device=${node.config.disko.devices.disk.main.device}"
    ]}'
    
''

