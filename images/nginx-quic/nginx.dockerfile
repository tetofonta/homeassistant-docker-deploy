FROM nginx:1.21.1 AS builder

RUN set -ex; apt-get update -y; apt-get install -y git gcc make g++ cmake perl libunwind-dev golang cmake automake libperl-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-ocaml-dev libgeoip-dev mercurial; mkdir /src

WORKDIR /src
RUN set -ex; hg clone -b quic https://hg.nginx.org/nginx-quic
RUN set -ex; hg clone http://hg.nginx.org/njs -r "0.6.2"
RUN set -ex; git clone https://github.com/google/boringssl

WORKDIR /src/boringssl
RUN set -ex; mkdir build; cd build; cmake ../; make -j 4

WORKDIR /src/nginx-quic
RUN set -ex; hg update quic
RUN set -ex; auto/configure `nginx -V 2>&1 | sed "s/ \-\-/ \\\ \n\t--/g" | grep "\-\-" | grep -ve opt= -e param= -e build=` --build=nginx-quic --with-debug --with-http_v3_module --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-stream_quic_module --with-http_random_index_module --with-cc-opt="-I/src/boringssl/include" --with-ld-opt="-L/src/boringssl/build/ssl -L/src/boringssl/build/crypto"
RUN set -ex; make -j 4;

FROM nginx:1.21.1
ENV CERT_LOCATION /etc/ssl/live

COPY --from=builder /src/nginx-quic/objs/nginx /usr/sbin
COPY ./cert-watch.sh /usr/sbin/cert-watch.sh

RUN set -ex; apt-get update -y; apt-get install -y cron; mkdir -p /cronjob
RUN set -ex; echo "* * * * *    sh /usr/sbin/cert-watch.sh" > /cronjob/root
RUN set -ex; crontab /cronjob/root

RUN set -ex; echo '#!/bin/sh \n cron -l 8 \n exec "$@"' > /init.sh
RUN set -ex; chmod +x /init.sh
RUN /usr/sbin/nginx -V > /dev/stderr; sleep 5

CMD ["/init.sh", "/usr/sbin/nginx", "-g", "daemon off;"]