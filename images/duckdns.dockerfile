FROM alpine:latest

ENV DOMAIN example
ENV TOKEN token

COPY update_duckdns.sh /update_duckdns.org

RUN apk update; apk add curl

CMD ["/bin/sh", "/update_duckdns.org" ]