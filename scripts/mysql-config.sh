#!/bin/bash

if [ ! "$AWS_ACCESS_KEY_ID" ] || [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Warning: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required to get the database. Skipping." >&2
  return
fi

if [ ! -f "/db-data/$PHILA_DB_FILE" ]; then
    #     # Install mysql client
    if ! type "mysql" > /dev/null; then
        apt-get update -y && apt-get install mysql-client -y
    fi

    if ! type "unzip" > /dev/null; then
        apt-get update -y && apt-get install -y unzip
    fi;

    echo "Downloading database... Please wait"
    s3_url="s3://$PHILA_DB_BUCKET/$PHILA_DB_FILE"
    aws s3 cp "$s3_url" "/db-data"

    pushd /var/www/html/

    maxcounter=12
    counter=1
    while ! wp db check --allow-root | grep -q "Success"; do
        sleep 2
        counter=`expr $counter + 1`
        if [ $counter -gt $maxcounter ]; then
            >&2 echo "Warning: We have been waiting for MySQL too long already; failing."
            break
        fi;
        echo "Warning: Let's try to connect to database again"
    done

    if [ -f "/db-data/$PHILA_DB_FILE" ]; then
        echo "Installing DB"
        wp db import --allow-root "/db-data/$PHILA_DB_FILE"
    fi

    popd
else
    echo "SQL file alredy exist inside db-data, do not need to download it";
fi

# /entrypoint.sh "$@"