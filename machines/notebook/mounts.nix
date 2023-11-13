{ nodes, config, ... }:

{
  fileSystems."/mnt/vault" = {
    device = "//${nodes."nas".config.dns.host.ipv4}/vault";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/vault/credentials".path}"
      "uid=fooker"
    ];
  };

  fileSystems."/mnt/cantina" = {
    device = "//10.32.30.95/cantina";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "credentials=${config.sops.secrets."mounts/cantina/credentials".path}"
    ];
  };

  sops.secrets."mounts/vault/credentials" = { };
  sops.secrets."mounts/cantina/credentials" = { };
}
