{ config, lib, pkgs, ... }:

let
  # rustc in stable 25.05 is too old for the pingora dependency tree,
  # so the package is built against <nixos-unstable> — same pattern
  # configuration.nix uses for other rust packages.
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };

  cfg = config.services.zedproxy;
in
{
  options.services.zedproxy = {
    enable = lib.mkEnableOption "zedproxy, the local reasoning_effort rewriting reverse proxy";

    package = lib.mkOption {
      type = lib.types.package;
      default = unstable.callPackage ../pkgs/zedproxy.nix { };
      defaultText = lib.literalExpression "unstable.callPackage ../pkgs/zedproxy.nix { }";
      description = "zedproxy package used by the service.";
    };

    upstreamUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://api.isoquant.ai/v1";
      description = "Upstream API base URL requests are proxied to.";
    };

    reasoningEffort = lib.mkOption {
      type = lib.types.str;
      default = "high";
      description = "Value substituted for reasoning_effort in proxied requests.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zedproxy = {
      description = "zedproxy — local reasoning_effort rewriting reverse proxy";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        ZEDPROXY_UPSTREAM_URL = cfg.upstreamUrl;
        ZEDPROXY_REASONING_EFFORT = cfg.reasoningEffort;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/zedproxy";
        DynamicUser = true;
        Restart = "on-failure";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
      };
    };
  };
}
