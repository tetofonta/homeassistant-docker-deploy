set -x
for i in $DOMAINS; do
    if [ -f /etc/letsencrypt/live/$i/.gen ]; then
        certbot renew --cert-name $i
    else
        rm -rf /etc/letsencrypt/live/$i
        rm -rf /etc/letsencrypt/archive/$i
        rm -rf /etc/letsencrypt/renewal/$i.conf
        
        email_arg=""
        if [ -z $EMAIL ]; then
            email_arg="--register-unsafely-without-email"
        else
            email_arg="--email ${EMAIL}"
        fi

        agree=""
        if [ "${AGREE_TOS}" == "true" ]; then   
            agree="--agree-tos"
        fi

        staging=""
        if [ "${STAGING}" == "true" ]; then   
            staging="--staging"
        fi

        certbot certonly -v --force-renewal --webroot -w /var/www/certbot $agree $email_arg $staging -d $i 
        touch /etc/letsencrypt/live/$i/.gen
    fi

    SHORT_NAME=$(echo $i | cut -d. -f1)
    if [ ! -d /etc/letsencrypt/live/$SHORT_NAME ]; then
        mkdir -p /etc/letsencrypt/live/$SHORT_NAME
    fi

    cp /etc/letsencrypt/live/$i/privkey.pem /etc/letsencrypt/live/$SHORT_NAME/privkey.pem
    cp /etc/letsencrypt/live/$i/fullchain.pem /etc/letsencrypt/live/$SHORT_NAME/fullchain.pem

    sleep 1
done