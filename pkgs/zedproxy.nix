{ pkgs }:

# Builds from the GitHub repository at a pinned commit hash.
# On a hash mismatch, nix prints the expected sha256; paste it
# below and rebuild.
pkgs.rustPlatform.buildRustPackage rec {
  pname = "zedproxy";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "s-zok";
    repo = "zedproxy";
    rev = "f557e385f70b5f4b67826c5d8c97a9b8f7175f38";
    hash = "sha256-d9gQrEAwShFv0uFQcXa7qNCXYe1jgBOxUCO6mCfIS8s=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  # libz-ng-sys (pingora compression deps) runs cmake at build time
  nativeBuildInputs = [ pkgs.cmake ];

  # pingora is built with the `rustls` feature — no openssl, no pkg-config.

  meta = with pkgs.lib; {
    description = "Local reverse proxy rewriting reasoning_effort for Zed compaction requests";
    license = licenses.mit;
    maintainers = [];
  };
}
