# General
[ ] Roll out `services.openssh.knownHosts` for all hosts on all hosts
[ ] Declarative config for syncthing (see https://git.darmstadt.ccc.de/maralorn/nixos-config/-/blob/master/common/common.nix)
    [ ] Open firewall ports for syncthing
    [ ] Can we do monitoring for folders?
[ ] Move around some services
    * gitea on brueckenkopf
[ ] Avoid double import of `findNixpkgs name` in deployment.nix
[ ] Deploy ROA checks for eBGP sessions
[ ] Central logging with loki
[ ] Generate `backhaul.deviceId` from index in node list
[ ] Enforce DNSSEC on all devices with fixed DNS server
[ ] Configure VLAN IDs via IPAM
[ ] Configure firewall network filters using IPAM (like nas/share)

# Router
[ ] Restarting systemd-netword crashes PPPoE

# Hive
[ ] Deploy monitoring user for mariadb
[ ] Declarative config of glusterfs

# Prusa
[ ] Use the reverse-proxy module
[ ] Use HLS / DASH streaming for camera
    * Compile ffmepg with omx and omx_rpi support
    * Patch Octoprint to support non-image video feeds
[ ] Install plugin for bed leveling
