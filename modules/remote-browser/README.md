# Remote browser

`modules.nixos.remote-browser` runs persistent Chromium through Selkies on NixOS using Docker. Chromium reopens automatically when its window is closed. The LinuxServer image is pinned by digest; updates require changing that pin. CPU rendering and encoding work without GPU passthrough.

The `remote-browser` system service listens for HTTP on `127.0.0.1:6080`, with Selkies's backend on loopback port 6082. Host networking lets Chromium reach development servers at the host's localhost. No source directories, host home, Docker socket, or GPU devices are mounted. The image disables Chromium's sandbox, so treat the container as a dedicated development browser, not an isolated security environment for untrusted browsing.

The host owns HTTPS exposure through a private reverse proxy. Use HTTPS; the streaming client requires a secure context. Do not expose the browser publicly.

Sign in as `browser`. The service generates a random password once in `/var/lib/remote-browser/password`, outside the Nix store. Read it locally with `sudo cat /var/lib/remote-browser/password`. The directory is root-only; restarting the service preserves the password. Basic authentication protects the page, its API, and direct backend connections. Desktop hardening disables the bundled shell/administration conveniences, file transfers, and printing.

The Docker volume `remote-browser`, mounted at `/config`, preserves the Chromium profile, cookies, extensions, and files across restarts and image updates. Removing the module does not delete this volume or the password. Back up the volume if these sessions matter; it contains private browser data.
