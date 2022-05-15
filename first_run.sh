docker-compose exec cfssl sh /bin/gen_crt.sh
docker-compose up -d
docker-compose exec certbot sh /certbot.entrypoint.sh
docker-compose exec nginx nginx -s reload