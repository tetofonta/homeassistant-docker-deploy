FROM alpine:3.15

USER root

ENV DOMAINS "example.com"
ENV EMAIL ""
ENV STAGING "false"
ENV AGREE_TOS "false"

COPY certbot.entrypoint.sh /certbot.entrypoint.sh
COPY prometheus_exporter.py /prometheus_exporter.py

RUN set -ex; apk add --update apk-cron certbot python3; rm -rf /var/cache/apk/*
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN set -ex; pip install prometheus_client pytz

RUN chmod 755 /certbot.entrypoint.sh
RUN echo '[ ! -f /etc/crontabs/root ] && echo "1 */12 * * *    sh /certbot.entrypoint.sh" > /etc/crontabs/root; nohup python3 /prometheus_exporter.py ; echo "starting cron..."; crond -f -l 8' > /bin/init.sh

RUN mkdir -p /etc/letsencrypt
RUN mkdir -p /var/www/certbot

VOLUME [ "/etc/letsencrypt" ]
VOLUME [ "/var/www/certbot" ]

ENTRYPOINT [ "sh" ]
CMD [ "/bin/init.sh" ]