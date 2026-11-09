#!/bin/sh
# Boot script for ownCloud Infinite Scale on Railway.
#  - one volume at $OCIS_VOLUME holds config ($OCIS_CONFIG_DIR) and data, so redeploys keep users and files
#  - Railway mounts volumes owned by root; chown it to uid 1000, write-test it, and fail loudly if it is not writable
#  - `ocis init` runs once (no config yet) with the admin password from OCIS_ADMIN_PASSWORD; secrets it generates stay in the volume
#  - listens on Railway's injected $PORT (the healthcheck dials it, not the domain's target port)
#  - OCIS_URL is the public https address; the built-in OIDC identity provider needs it to be exact
set -eu

VOL="${OCIS_VOLUME:-/var/lib/ocis}"
CFG="${OCIS_CONFIG_DIR:-$VOL/config}"
: "${OCIS_ADMIN_PASSWORD:?OCIS_ADMIN_PASSWORD must be set (the template generates it)}"
: "${OCIS_URL:?OCIS_URL must be set (the template sets https://RAILWAY_PUBLIC_DOMAIN)}"

mkdir -p "$VOL" "$CFG"
echo "[railway] volume $VOL owner uid=$(stat -c %u "$VOL")"
chown -R 1000:1000 "$VOL"
if ! su-exec 1000:1000 sh -c "touch '$VOL/.write-test' && rm -f '$VOL/.write-test'"; then
  echo "[railway] FATAL: $VOL is not writable by uid 1000"; exit 1
fi

if [ ! -s "$CFG/ocis.yaml" ]; then
  echo "[railway] first boot: ocis init"
  su-exec 1000:1000 \
    /usr/bin/ocis init --insecure yes --admin-password "$OCIS_ADMIN_PASSWORD" --config-path "$CFG"
fi

export PROXY_HTTP_ADDR="0.0.0.0:${PORT:-9200}"
export OCIS_URL
echo "[railway] listening on $PROXY_HTTP_ADDR, public URL $OCIS_URL"
exec su-exec 1000:1000 /usr/bin/ocis "$@"
