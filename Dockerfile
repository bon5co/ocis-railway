# ownCloud Infinite Scale (oCIS) for Railway.
# Upstream pinned by digest. The wrapper runs as root only long enough to chown the Railway volume,
# creates the oCIS config with a generated admin password on first boot, binds Railway's injected PORT
# and then drops to uid 1000 (the upstream user) before starting the server.
FROM owncloud/ocis@sha256:9a4f33607cb8337b15815d84e608afe55a7089859260fb4e896cda8d69591760

USER root
RUN apk add --no-cache su-exec

ENV OCIS_VOLUME=/var/lib/ocis \
    OCIS_BASE_DATA_PATH=/var/lib/ocis \
    OCIS_CONFIG_DIR=/var/lib/ocis/config \
    OCIS_INSECURE=true \
    PROXY_TLS=false \
    PROXY_ENABLE_BASIC_AUTH=true \
    OCIS_LOG_LEVEL=warn \
    START_ADDITIONAL_SERVICES=notifications

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/railway-entrypoint.sh

EXPOSE 9200
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["server"]
