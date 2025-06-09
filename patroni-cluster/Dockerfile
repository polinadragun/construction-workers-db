FROM postgres:15

RUN apt-get update && \
    apt-get install -y python3-pip curl netcat-openbsd etcd-client && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages 'patroni[etcd3]' 'psycopg[binary]'

COPY ./patroni-entry.sh /patroni-entry.sh
COPY ./scripts/init.sh /init.sh

RUN chmod 755 /patroni-entry.sh /init.sh && \
    chown postgres:postgres /patroni-entry.sh /init.sh && \
    mv /patroni-entry.sh /usr/local/bin/ && \
    mv /init.sh /var/lib/postgresql/

USER postgres

ENTRYPOINT ["/usr/local/bin/patroni-entry.sh"]