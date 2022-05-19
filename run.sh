export UID
export GID

DATA_DIRECTORY=${DATA_DIRECTORY:-"./data"}
export DATA_DIRECTORY=${DATA_DIRECTORY}

docker-compose up -d