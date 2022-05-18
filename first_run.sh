docker-compose pull
docker-compose build
docker-compose run --rm cfssl /bin/gen_crt.sh
docker-compose up -d
sleep 10
docker-compose run --rm certbot /certbot.entrypoint.sh
docker-compose exec nginx nginx -s reload