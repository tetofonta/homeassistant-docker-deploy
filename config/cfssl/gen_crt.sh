#!/bin/bash

set -e

[ ! -d /etc/ssl/ca ] && mkdir -p /etc/ssl/ca
[ ! -d /etc/ssl/ca_intermediate ] && mkdir -p /etc/ssl/ca_intermediate
[ ! -d /etc/ssl/certs ] && mkdir -p /etc/ssl/certs

if [ ! -f  /etc/ssl/ca/ca.pem -o ! -f /etc/ssl/ca/ca-key.pem ]; then
    cfssl gencert -initca /etc/sslconf/ca.json | cfssljson -bare /etc/ssl/ca/ca
    chmod 600 /etc/ssl/ca/ca-key.pem
    chmod 644 /etc/ssl/ca/ca.pem
    chmod 750 /etc/ssl/ca/ 
    chown -R root:root /etc/ssl/ca/ 
fi

if [ ! -f  /etc/ssl/ca_intermediate/intermediate_ca.pem -o ! -f /etc/ssl/ca_intermediate/intermediate_ca-key.pem ]; then
    cfssl gencert -initca /etc/sslconf/intermediate.json | cfssljson -bare /etc/ssl/ca_intermediate/intermediate_ca    
    cfssl sign -ca /etc/ssl/ca/ca.pem -ca-key /etc/ssl/ca/ca-key.pem -config /etc/sslconf/cfssl.json -profile intermediate_ca /etc/ssl/ca_intermediate/intermediate_ca.csr | cfssljson -bare /etc/ssl/ca_intermediate/intermediate_ca
    cat /etc/ssl/ca_intermediate/intermediate_ca.pem /etc/ssl/ca/ca.pem > /etc/ssl/ca_intermediate/intermediate_ca_fullchain.pem

    chmod 600 /etc/ssl/ca_intermediate/intermediate_ca-key.pem
    chmod 644 /etc/ssl/ca_intermediate/intermediate_ca.pem
    chmod 644 /etc/ssl/ca_intermediate/intermediate_ca_fullchain.pem
    chmod 750 /etc/ssl/ca_intermediate/ 
    chown -R root:root /etc/ssl/ca_intermediate/ 
fi

for CRT in /etc/sslconf/certificates/*.json ; do
    NAME=$(basename $CRT .json)
    FULLNAME="/etc/ssl/certs/${NAME}"

    if [ ! -f /etc/sslconf/.regenerate -a -d "$FULLNAME" ]; then
        continue
    fi

    mkdir -p "$FULLNAME"

    cfssl gencert -ca /etc/ssl/ca_intermediate/intermediate_ca.pem -ca-key /etc/ssl/ca_intermediate/intermediate_ca-key.pem -config /etc/sslconf/cfssl.json -profile=host $CRT | cfssljson -bare "${FULLNAME}/${NAME}"
    cat "${FULLNAME}/${NAME}.pem" /etc/ssl/ca_intermediate/intermediate_ca.pem > "${FULLNAME}/fullchain.pem"
    mv "${FULLNAME}/${NAME}-key.pem" "${FULLNAME}/privkey.pem"
    rm "${FULLNAME}/${NAME}.pem" "${FULLNAME}/${NAME}.csr"

    chmod 600 "${FULLNAME}/privkey.pem"
    chmod 644 "${FULLNAME}/fullchain.pem"
    chmod 750 "${FULLNAME}"
    chown -R root:root "${FULLNAME}"
done

for CRT in /etc/sslconf/tmp_certificates/*.json ; do
    NAME=$(basename $CRT .json)
    FULLNAME="/etc/tmp_ssl/${NAME}"

    if [ ! -f /etc/sslconf/.regenerate -a -d "$FULLNAME" ]; then
        continue
    fi

    mkdir -p "$FULLNAME"

    cfssl gencert -ca /etc/ssl/ca_intermediate/intermediate_ca.pem -ca-key /etc/ssl/ca_intermediate/intermediate_ca-key.pem -config /etc/sslconf/cfssl.json -profile=host $CRT | cfssljson -bare "${FULLNAME}/${NAME}"
    cat "${FULLNAME}/${NAME}.pem" /etc/ssl/ca_intermediate/intermediate_ca.pem > "${FULLNAME}/fullchain.pem"
    mv "${FULLNAME}/${NAME}-key.pem" "${FULLNAME}/privkey.pem"
    rm "${FULLNAME}/${NAME}.pem" "${FULLNAME}/${NAME}.csr"

    chmod 600 "${FULLNAME}/privkey.pem"
    chmod 644 "${FULLNAME}/fullchain.pem"
    chmod 750 "${FULLNAME}"
    chown -R root:root "${FULLNAME}"
done
