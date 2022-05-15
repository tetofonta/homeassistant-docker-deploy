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

EXPOSE 8888

VOLUME ["/etc/sslconf"]
VOLUME ["/etc/ssl"]
VOLUME ["/etc/tmp_ssl"]

ENTRYPOINT ["/bin/ash"]
CMD ["/bin/gen_crt.sh"]