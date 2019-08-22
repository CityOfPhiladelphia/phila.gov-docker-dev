#!/bin/bash

rm -r /var/www/html

cd /

# if [ -z "$(ls -A /phila.gov)" ]; then
if [ ! -f /phila.gov/wp/wp-config-sample.php ] || [ ! -f /phila.gov/wp/index.php ]; then
    printf $'\e[33mIt looks like phila.gov does not exists, downloading...\e[0m\n'
    # Removing a possible existing repo
    rm -vR /phila.gov/*; rm -vR /phila.gov/.*; git clone https://github.com/CityOfPhiladelphia/phila.gov.git && ln -s /phila.gov/wp /var/www/html
else
    ln -s /phila.gov/wp /var/www/html
fi
