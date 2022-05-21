FROM golang:1.18.2-alpine3.15 as builder

WORKDIR /workdir

RUN set -x && \
	apk --no-cache add git gcc libc-dev make

RUN git clone https://github.com/cloudflare/cfssl.git .

RUN git clone https://github.com/cloudflare/cfssl_trust.git /etc/cfssl && \
    make clean && \
    make bin/rice && ./bin/rice embed-go -i=./cli/serve && \
    make all



FROM alpine:3.15
COPY --from=builder /etc/cfssl /etc/cfssl
COPY --from=builder /workdir/bin/ /usr/bin
COPY gen_crt.sh /bin/gen_crt.sh

RUN set -ex; apk add --update apk-cron; rm -rf /var/cache/apk/*
RUN chmod 755 /bin/gen_crt.sh;
RUN echo -e '[ ! -f /cronjob/root ] && echo "*/15 * * * *    sh /bin/gen_crt.sh" > /cronjob/root \n echo "starting cron..." \n crontab /cronjob/root \n exec crond -f -l 0' > /bin/init.sh

VOLUME ["/etc/sslconf"]
VOLUME ["/etc/ssl"]
VOLUME ["/etc/tmp_ssl"]

ENTRYPOINT ["sh"]
CMD ["/bin/init.sh"]