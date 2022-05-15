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
RUN chmod 755 /bin/gen_crt.sh; echo "* * * * *    /bin/gen_crt.sh" > /etc/crontabs/root
RUN echo 'sh /bin/gen_crt.sh; echo "starting cron..."; crond -f -l 8' > /bin/init.sh

VOLUME ["/etc/sslconf"]
VOLUME ["/etc/ssl"]
VOLUME ["/etc/tmp_ssl"]

ENTRYPOINT ["sh", "/bin/init.sh"]