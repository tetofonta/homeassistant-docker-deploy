#!/bin/sh

LAST_RELOAD=0
if [ -f /tmp/cert-watch.last_reload ]; then
    LAST_RELOAD=$(cat /tmp/cert-watch.last_reload)
fi


CHANGED=0
for f in ${CERT_LOCATION}/*/fullchain.pem; do
    if [ -f "$f" ]; then
        if [ "$(stat -c %Y "$f")" -gt LAST_RELOAD ]; then
            CHANGED=1
            break
        fi
    fi
done

if [ $CHANGED -eq 1 ]; then
    echo "Certificate changed, reloading nginx"
    /usr/sbin/nginx -t && /usr/sbin/nginx -s reload
    echo $(date +%s) > /tmp/cert-watch.last_reload
fi