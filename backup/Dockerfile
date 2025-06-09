FROM postgres:15

RUN apt-get update && \
    apt-get install -y cron gettext && \
    rm -rf /var/lib/apt/lists/*

COPY backup.sh /backup.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /backup.sh

ENTRYPOINT ["/entrypoint.sh"]