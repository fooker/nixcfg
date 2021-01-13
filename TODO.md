# General
[ ] Roll out `services.openssh.knownHosts` for all hosts on all hosts
[ ] Declarative config for syncthing (see https://git.darmstadt.ccc.de/maralorn/nixos-config/-/blob/master/common/common.nix)
[ ] Open firewall ports for syncthing
[ ] Log rejected routes in backhaul
[ ] Backhaul opens ports for unused protocols in firewall
[ ] Move around some services
    * home-assistant + mosquitto on toiler (ACLs on router)
    * gitea on brueckenkopf
[ ] Collect backup keys from defined machines
[ ] Avoid double import of `findNixpkgs name` in deployment.nix
[ ] Make backhaul.peer.remote a optional submodule
[ ] Only enable forwarding on specific interfaces (backhaul and router)

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
[ ] Bump stateVersion to 20.09 to update jellyfin