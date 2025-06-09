#!/bin/bash
set -e

IFS=',' read -ra USERSTOGRANT <<< "$ANALYST_NAMES"

DB_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

run() {
  psql "$DB_URL" <<EOF
$1
EOF
}

sleep 5
psql -U postgres -d postgres -c "CREATE DATABASE construction-workers-db;"
psql -U postgres -d postgres -c "ALTER DATABASE construction-workers-db OWNER TO postgres;"

for username in "${USERSTOGRANT[@]}"; do
  if [[ ! "$username" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "Invalid username: $username" >&2
    exit 1
  fi
done

run "
CREATE ROLE analytic;
GRANT USAGE ON SCHEMA public TO analytic;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytic;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO analytic;
"

for username in "${USERSTOGRANT[@]}"; do
  run "
  DO \$\$
  BEGIN
  EXECUTE format('CREATE USER %I WITH PASSWORD %L', '${username}', '${username}_123');
  EXECUTE format('GRANT analytic TO %I', '${username}');
  END
  \$\$;
"
done

run "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
