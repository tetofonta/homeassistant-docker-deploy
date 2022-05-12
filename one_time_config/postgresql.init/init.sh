#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${AUTHENTIK_POSTGRESQL__USER} WITH ENCRYPTED PASSWORD '${AUTHENTIK_POSTGRESQL__PASSWORD}';
	CREATE DATABASE ${AUTHENTIK_POSTGRESQL__NAME};
	GRANT ALL PRIVILEGES ON DATABASE ${AUTHENTIK_POSTGRESQL__NAME} TO ${AUTHENTIK_POSTGRESQL__USER};

    CREATE USER ${HASS_POSTGRESQL__USER} WITH ENCRYPTED PASSWORD '${HASS_POSTGRESQL__PASSWORD}';
	CREATE DATABASE ${HASS_POSTGRESQL__DB};
	GRANT ALL PRIVILEGES ON DATABASE ${HASS_POSTGRESQL__DB} TO ${HASS_POSTGRESQL__USER};
EOSQL