# General
[ ] Roll out `services.openssh.knownHosts` for all hosts on all hosts
[ ] Declarative config for syncthing (see https://git.darmstadt.ccc.de/maralorn/nixos-config/-/blob/master/common/common.nix)
[ ] Open firewall ports for syncthing
[ ] Log rejected routes in peering
[ ] Move around some services
    * home-assistant + mosquitto on toiler (ACLs on router)
    * gitea on brueckenkopf
[ ] Avoid double import of `findNixpkgs name` in deployment.nix
[ ] Deploy ROA checks for eBGP sessions
[ ] Deploy SSHFP records per host
[ ] Unify dns.host and network config
[ ] Central logging with loki
[ ] Generate `backhaul.deviceId` from index in node list

# Router
[ ] Restarting systemd-netword crashes PPPoE

# Hive
[ ] Deploy monitoring user for mariadb
[ ] Declarative config of glusterfs

# NAS
[ ] Get rid of NFS (or make it secure)

# Scanner
[ ] Activate Timer
[ ] Do the real upload

# Prusa
[ ] Use HLS / DASH streaming for camera
    * Compile ffmepg with omx and omx_rpi support
    * Patch Octoprint to support non-image video feeds
[ ] Install plugin for bed leveling

# Toiler
[ ] Fix the spotifyd workaround
