#!/bin/bash
set -e

if [ -d "/data/patroni" ]; then
    echo "Setting permissions for /data/patroni"
    chown -R postgres:postgres /data/patroni
    chmod -R 750 /data/patroni
else
    echo "Warning: /data/patroni directory not found"
fi

echo "Waiting for etcd to become available"
until nc -z -w 2 etcd 2379; do
    echo "Waiting for etcd"
    sleep 2
done

echo "Verifying etcd health"
until etcdctl endpoint health --endpoints=http://etcd:2379; do
    echo "Waiting for etcd to be healthy"
    sleep 2
done

echo "starting patroni"
exec patroni /etc/patroni.yml