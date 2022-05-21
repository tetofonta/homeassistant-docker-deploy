FROM rclone/rclone:1.58 as builder


RUN set -ex; apk add --update apk-cron; rm -rf /var/cache/apk/*
RUN echo -e 'nohup rclone rcd --rc-web-gui --rc-addr :5572 --rc-no-auth --rc-enable-metrics --rc-cert=/ssl/fullchain.pem --rc-key=/ssl/privkey.pem & \n echo "starting cron..." \n [ -f /cronjob/root ] && crontab /cronjob/root \n exec crond -f -l 0' > /bin/init.sh


VOLUME ["/backup"]
ENTRYPOINT ["/bin/sh"]
CMD ["/bin/init.sh"]