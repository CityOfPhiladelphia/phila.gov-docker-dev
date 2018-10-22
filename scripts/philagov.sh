#!/bin/bash

rm -r /var/www/html

cd /

if [ -z "$(ls -A /phila.gov)" ]; then
    echo "Info: Phila.gov does not exist, downloading... Please, wait"
    git clone https://github.com/CityOfPhiladelphia/phila.gov.git
fi

echo "Creating symlink"
ln -s /phila.gov/wp /var/www/html