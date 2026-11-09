# ocis-railway

Wrapper image for [ownCloud Infinite Scale](https://github.com/owncloud/ocis) (oCIS, a file sync and sharing server with WebDAV, Graph API and a built-in identity provider) on Railway.

The upstream image is pinned by digest. The wrapper adds an entrypoint that:

- chowns the Railway volume (mounted root-owned) to uid 1000, write-tests it and fails loudly when it is not writable,
- runs `ocis init` once, on first boot, with the admin password from `OCIS_ADMIN_PASSWORD`; generated secrets and the config stay on the volume,
- listens on Railway's injected `PORT` (Railway's HTTP healthcheck dials it) and takes its public address from `OCIS_URL`,
- enables HTTP basic auth on the proxy so scripts and agents can call WebDAV and the Graph API without an OIDC flow,
- drops to uid 1000 before starting the server.

Mount one volume at `/var/lib/ocis`. Published as `ghcr.io/bon5co/ocis-railway`. Used by the Railway template "ownCloud Infinite Scale".
