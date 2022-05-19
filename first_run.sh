export UID
export GID

DATA_DIRECTORY=${DATA_DIRECTORY:-"./data"}
export DATA_DIRECTORY=${DATA_DIRECTORY}

mkdir -p "${DATA_DIRECTORY}"
mkdir -p "${DATA_DIRECTORY}/authentik"
mkdir -p "${DATA_DIRECTORY}/certwww"
mkdir -p "${DATA_DIRECTORY}/geoip"

mkdir -p "${DATA_DIRECTORY}/graphana"
sudo chown 472:472 "${DATA_DIRECTORY}/graphana"

mkdir -p "${DATA_DIRECTORY}/homeassistant"
mkdir -p "${DATA_DIRECTORY}/pgadmin"
mkdir -p "${DATA_DIRECTORY}/portainer"

mkdir -p "${DATA_DIRECTORY}/postgresql"
sudo chown 70:70 "${DATA_DIRECTORY}/postgresql"

mkdir -p "${DATA_DIRECTORY}/prometheus"
sudo chown 65534:65534 "${DATA_DIRECTORY}/prometheus"

mkdir -p "${DATA_DIRECTORY}/ssl"

docker-compose pull
docker-compose build
docker-compose run --rm cfssl /bin/gen_crt.sh
docker-compose up -d
docker-compose run --rm certbot /certbot.entrypoint.sh
docker-compose exec nginx nginx -s reload