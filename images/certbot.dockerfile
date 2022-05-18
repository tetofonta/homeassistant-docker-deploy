FROM alpine:3.15

USER root

ENV DOMAINS "example.com"
ENV EMAIL ""
ENV STAGING "false"
ENV AGREE_TOS "false"

COPY certbot.entrypoint.sh /certbot.entrypoint.sh

RUN set -ex; apk add --update apk-cron certbot; rm -rf /var/cache/apk/*
RUN chmod 755 /certbot.entrypoint.sh
RUN echo '[ ! -f /etc/crontabs/root ] && echo "1 */12 * * *    sh /certbot.entrypoint.sh" > /etc/crontabs/root; echo "starting cron..."; crond -f -l 8' > /bin/init.sh
RUN mkdir -p /etc/letsencrypt
RUN mkdir -p /var/www/certbot

VOLUME [ "/etc/letsencrypt" ]
VOLUME [ "/var/www/certbot" ]

ENTRYPOINT [ "sh" ]
CMD [ "/bin/init.sh" ]