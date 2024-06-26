#!/bin/bash

clear
echo "Creating directory structure for CA"
mkdir -p data/ssl/certs
mkdir -p data/ssl/csr
mkdir -p data/ssl/private
mkdir -p data/ssl/newcerts
touch data/ssl/index.txt
echo "unique_subject = yes" > data/ssl/index.txt.attr

if [[ ! -f data/ssl/serial ]]; then
	echo Creating serial file
	echo 1000 > data/ssl/serial
fi

clear

if [[ ! -f "data/ssl/private/myCA.key" ]]; then
	echo "Creating key for personal CA, please fill out the FQDN with the name you want for your CA"
	echo ""
	openssl genrsa -aes256 -out data/ssl/private/myCA.key 4096
	chmod 500 data/ssl/private/myCA.key
	echo "Creating personal CA"
	echo ""
	openssl req -config data/ssl/vaultwarden.ext -x509 -new -sha256 -days 3650 -extensions v3_ca -key data/ssl/private/myCA.key -out data/ssl/certs/myCA.crt
	clear
fi 
	
echo "Creating key for vaultwarden certificate"
echo ""
openssl genrsa -out data/ssl/private/vaultwarden.key 2048
echo "Creating request for vaultwarden certificate, please fill out the FQDN with the name that the instance will be located at"
echo ""
openssl req -config data/ssl/vaultwarden.ext -key data/ssl/private/vaultwarden.key -new -sha256 -out data/ssl/csr/vaultwarden.csr
echo ""
clear
echo -n "Please enter your FQDN for your vaultwarden instance: "
read answer
sed -i "/DNS.1 = */c\DNS.1 = $answer" ./data/ssl/vaultwarden.ext
sed -i "/DNS.2 = */c\DNS.2 = www.$answer" ./data/ssl/vaultwarden.ext
openssl ca -config data/ssl/vaultwarden.ext -extensions server_cert -days 365 -notext -md sha256 -in data/ssl/csr/vaultwarden.csr -out data/ssl/certs/vaultwarden.crt
echo ""
echo "Your personal CA has been created, please make sure to install myCA.crt as a trusted root CA in all devices you want to connect to this instance"
