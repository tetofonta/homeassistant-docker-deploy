docker-compose pull
docker-compose build
docker-compose up cfssl -d
sleep 15
docker-compose up -d
sleep 120
docker-compose exec certbot sh /certbot.entrypoint.sh
docker-compose exec nginx nginx -s reload