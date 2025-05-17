FROM postgres:16

COPY scripts/init/analytics.sh /docker-entrypoint-initdb.d/analytics.sh

RUN chmod +x /docker-entrypoint-initdb.d/analytics.sh