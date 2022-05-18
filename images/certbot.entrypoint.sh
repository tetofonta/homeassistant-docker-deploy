set -x
for subdomain in $SUBDOMAINS; do
    full_domain="${subdomain}.${DOMAIN}"
    if [ -f /etc/letsencrypt/live/$full_domain/.gen ]; then
        certbot renew --cert-name $full_domain
    else
        rm -rf /etc/letsencrypt/live/$full_domain
        rm -rf /etc/letsencrypt/archive/$full_domain
        rm -rf /etc/letsencrypt/renewal/$full_domain.conf
        
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

        certbot certonly -v --force-renewal --webroot -w /var/www/certbot $agree $email_arg $staging -d $full_domain 
        touch /etc/letsencrypt/live/$full_domain/.gen
    fi

    if [ ! -d /etc/letsencrypt/live/$subdomain ]; then
        mkdir -p /etc/letsencrypt/live/$subdomain
    fi

    cp /etc/letsencrypt/live/$full_domain/privkey.pem /etc/letsencrypt/live/$subdomain/privkey.pem
    cp /etc/letsencrypt/live/$full_domain/fullchain.pem /etc/letsencrypt/live/$subdomain/fullchain.pem

    sleep 1
done