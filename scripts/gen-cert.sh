#!/bin/bash

# If certs already exist, return
if [ -f /etc/nginx/certs/localhost.key ]; then
  printf $'\e[36mSSL certificate \e[33malready exists. Skipping.\e[0m\n'
  return
fi

echo "Generating SSL certificate"
pushd /etc/nginx/certs/
openssl req -x509 -out localhost.crt -keyout localhost.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
popd
