{ pkgs, lib, config, name, ... }:

with lib;

let
  mkPeerPage = peer: pkgs.writeText "peering-info.${peer.name}.html" ''
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">

      <link href="/bootstrap/css/bootstrap.min.css" rel="stylesheet">

      <title>Peering Information - ${peer.name}</title>
    </head>
    <body>
      <div class="col-lg-8 mx-auto p-3 py-md-5"">
        <header class="d-flex align-items-center pb-3 mb-5 border-bottom">
          <h2><samp>${peer.name}</samp> ⇌ <samp>${name}</samp></h2>
        </header>
        <main>
          <div class="row">
            <div class="col-6">
              <h3>Wireguard:</h3>
              <dl class="row">
                <dt class="col-sm-3">My Endpoint</dt>
                <dd class="col-sm-9"><samp>${config.dns.host.domain.toSimpleString}:${toString peer.local.port}</samp></dd>

                <dt class="col-sm-3">My Public Key</dt>
                <dd class="col-sm-9"><samp>${peer.local.pubkey}</samp></dd>
                
                <dt class="col-sm-3">Your Endpoint</dt>
                <dd class="col-sm-9">${if (peer.remote.endpoint != null) then ''
                  <samp>${peer.remote.endpoint.host}:${toString peer.remote.endpoint.port}</samp>
                '' else ''
                  <span class="text-muted">dynamic</span>
                ''}</dd>
                
                <dt class="col-sm-3">Your Public Key</dt>
                <dd class="col-sm-9"><samp>${peer.remote.pubkey}</samp></dd>
              </dl>

              ${optionalString (peer.transfer.ipv4 != null) ''
              <h3>Transfer Network - IPv4:</h3>
              <dl class="row">
                <dt class="col-sm-3">My Address</dt>
                <dd class="col-sm-9"><samp>${peer.transfer.ipv4.addr}</samp></dd>
                
                <dt class="col-sm-3">Your Address</dt>
                <dd class="col-sm-9"><samp>${peer.transfer.ipv4.peer}</samp></dd>
              </dl>
              ''}

              ${optionalString (peer.transfer.ipv6 != null) ''
              <h3>Transfer Network - IPv6:</h3>
              <dl class="row">
                <dt class="col-sm-3">My Address</dt>
                <dd class="col-sm-9"><samp>${peer.transfer.ipv6.addr}</samp></dd>
                
                <dt class="col-sm-3">Your Address</dt>
                <dd class="col-sm-9"><samp>${peer.transfer.ipv6.peer}</samp></dd>
              </dl>
              ''}
            </div>
            <div class="col-6">
              ${concatMapStringsSep "\n" (name: let
                domain = config.peering.domains.${name};
              in optionalString (elem name config.peering.info.domains) ''
              <h3>Node - ${name}:</h3>
              <dl class="row">
                <dt class="col-sm-3">My IPv4</dt>
                <dd class="col-sm-9"><samp>${toString domain.ipv4}</samp></dd>

                <dt class="col-sm-3">My IPv6</dt>
                <dd class="col-sm-9"><samp>${toString domain.ipv6}</samp></dd>
              </dl>

              ${optionalString (domain.bgp != null && peer.domains.${name}.bgp != null) ''
              <h3>BGP - ${name}:</h3>
              <dl class="row">
                <dt class="col-sm-3">My AS</dt>
                <dd class="col-sm-9"><samp>${toString domain.bgp.as}</samp></dd>

                <dt class="col-sm-3">Your AS</dt>
                <dd class="col-sm-9">${if (peer.domains.${name}.bgp.as != null) then ''
                  <samp>${toString peer.domains.${name}.bgp.as}</samp>
                '' else ''
                  <span class="text-muted">interior</span>
                ''}</dd>
              </dl>
              ''}

              <h3>My Exports - ${name}:</h3>
              <ul>
                ${concatMapStringsSep "\n" (export: ''
                <li><samp>${export}</samp></li>
                '') (domain.exports.ipv4 ++ domain.exports.ipv6)}
              </ul>

              <h3>My Filters - ${name}:</h3>
              <ul>
                ${concatMapStringsSep "\n" (filter: ''
                <li><samp>${filter}</samp></li>
                '') (domain.filters.ipv4 ++ domain.filters.ipv6)}
              </ul>
              '') (attrNames peer.domains)}
            </div>
          </div>
        </main>
      </div>
    </body>
    </html>
  '';

  root = pkgs.linkFarm "peering-info" (
    (map
      (peer: {
        name = "${peer.name}.html";
        path = mkPeerPage peer;
      })
      (attrValues config.peering.peers))
    ++ [{
      name = "bootstrap";
      path = pkgs.twitterBootstrap;
    }]
  );
in
{
  options.peering.info = {
    enable = mkEnableOption "Peering Info Website";

    domains = mkOption {
      type = types.listOf (types.enum (attrNames config.peering.domains));
      description = ''
        The domains to display peering information for.
      '';
    };
  };

  config = mkIf config.peering.info.enable {
    web.apps = {
      "peering-info" = {
        domains = [ config.dns.host.domain.toSimpleString ];
        inherit root;
      };
    };
  };
}
