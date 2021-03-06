#!/bin/bash

maxcounter=5
counter=1

pushd /var/www/html/

while ! wp db check --allow-root | grep -q "Success"; do
    sleep 3
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 printf $'\e[33mWe have been waiting for MySQL service for too long, are you sure the MySQL container is up and running?\; \e[31mFailing...\e[0m\n'
        return
    fi;
    printf $'\e[33mWARNING: Let\'s try to connect to database again try %s of %s  \e[0m\n' $counter $maxcounter
done

if wp db tables --allow-root | grep -q "wp_users"; then
    >&2 printf $'\e[36mDatabase \e[33mis intalled and runing! Skipping...\e[0m\n'
    return
fi

popd

YELLOW='\033[1;33m' && NC='\033[0m'

if [ ! "$AWS_ACCESS_KEY_ID" ] || [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
  printf $'\e[33mWARNING: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required to get the database. Skipping.$\e[0m' >&2
  return
fi

read -p $'\e[33mWARNING: Hey, look at here!
Would you like to download the phila.gov database inside the db/ folder? [Y/n]\e[0m: ' download
echo #Emtpy line, you know.

if [[ $download =~ ^[Yy]$ ]]; then
    if [ -f "/db/$PHILA_DB_FILE" ]; then
        read -p $'\e[33mWARNING: Oh my gosh!
I found a current.sql file inside the db folder,
would you like to override it? [Y/n]\e[0m: ' rewriteit
        echo #Emtpy line, you know.
        download=$rewriteit
    fi
fi

if [[ $download =~ ^[Yy]$ ]]; then
    printf $'\e[33mI hope you know what you are doing... =)\e[0m:\n'
    printf $'\e[31mDeleting Current current.sql file =/\e[0m:\n'
    rm -r /db/current.sql
else
    echo "We will skip the download..."
fi

if [[ $download =~ ^[Yy]$ ]]; then
    if ! type "unzip" > /dev/null; then
        apt-get update -y && apt-get install -y unzip
    fi;

    echo "Downloading database... Please wait"
    s3_url="s3://$PHILA_DB_BUCKET/$PHILA_DB_FILE"
    aws s3 cp "$s3_url" "/db"
fi

pushd /var/www/html/

if [ -f "/db/$PHILA_DB_FILE" ]; then
    read -p $'\e[33mWARNING: Now importing!
Would you like to import the current.sql file into your database? [Y/n]\e[0m: ' import
    echo    # (optional) move to a new line
    if [[ $import =~ ^[Yy]$ ]]; then
        printf $'\e[33mInstalling DB$\e[0m\n'
        wp db import --allow-root --debug=bootstrap "/db/$PHILA_DB_FILE"
    fi
fi

popd
