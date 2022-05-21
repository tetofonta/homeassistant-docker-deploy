FROM rclone/rclone:1.58 as builder


RUN set -ex; apk add --update apk-cron; rm -rf /var/cache/apk/*
RUN echo 'echo "starting cron..."; crond -l 8; rclone rcd --rc-web-gui --rc-addr :5572 --rc-no-auth --rc-cert=/ssl/fullchain.pem --rc-key=/ssl/privkey.pem' > /bin/init.sh


VOLUME ["/backup"]
ENTRYPOINT ["/bin/sh"]
CMD ["/bin/init.sh"]