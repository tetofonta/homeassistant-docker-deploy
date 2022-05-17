FROM rclone/rclone:1.58 as builder

COPY ./backups.sh /backups.sh

ENV BACKUP_DESTINATION ""

RUN set -ex; apk add --update apk-cron; rm -rf /var/cache/apk/*
RUN chmod 755 /backups.sh; echo "0 */6 * * *    sh /backups.sh" > /etc/crontabs/root
RUN echo 'echo "starting cron..."; crond -l 8; rclone rcd --rc-web-gui --rc-addr :5572 --rc-no-auth --rc-cert=/ssl/fullchain.pem --rc-key=/ssl/privkey.pem' > /bin/init.sh


VOLUME ["/backup"]
ENTRYPOINT ["/bin/sh"]
CMD ["/bin/init.sh"]