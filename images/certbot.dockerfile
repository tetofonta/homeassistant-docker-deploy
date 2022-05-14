FROM alpine:latest

USER root

ENV DOMAINS "example.com"
ENV EMAIL ""
ENV STAGING "false"
ENV AGREE_TOS "false"

COPY certbot.entrypoint.sh /certbot.entrypoint.sh

RUN set -ex; apk update; apk add certbot
RUN mkdir -p /etc/letsencrypt
RUN mkdir -p /var/www/certbot

VOLUME [ "/etc/letsencrypt" ]
VOLUME [ "/var/www/certbot" ]

CMD [ "sh", "/certbot.entrypoint.sh" ]