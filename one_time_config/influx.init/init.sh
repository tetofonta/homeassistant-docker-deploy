#!/bin/sh

influxd &

while :; do
    RET=$(influx ping --host https://localhost:8086 --skip-verify)
    echo $RET
    if [ "$RET" == "OK" ]; then
        break
    fi
    sleep 1
done


if [ ! -f /root/.influxdbv2/configd ]; then
    rm -v /etc/influxdb2/influx-configs
    influx setup --host https://localhost:8086 --skip-verify --http-debug --force --org "${INFLUX_ORG_NAME}" --bucket "${INFLUX_BUCKET}" --username "${INFLUX_USER}" --password "${INFLUX_PASSWORD}" --token "${INFLUX_TOKEN}"
    touch /root/.influxdbv2/configd
fi

while :; do
    sleep 5
done