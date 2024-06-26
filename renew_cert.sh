#!/bin/bash
# Look up the serial number of the cert to revoke on the cert itself on the webserver
# By default it should be 1000

if [ $# = 0 ]
then
  cert=1000
else
  cert=$1
fi

cp data/ssl/certs/vaultwarden.crt data/ssl/certs/vaultwarden.crt.bak
openssl ca -revoke data/ssl/newcerts/$cert.pem -config data/ssl/vaultwarden.ext
openssl ca -config data/ssl/vaultwarden.ext -extensions server_cert -days 365 -notext -md sha256 -in data/ssl/csr/vaultwarden.csr -out data/ssl/certs/vaultwarden.crt
