#!/bin/bash

if [ ! "$AWS_ACCESS_KEY_ID" ] || [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "WARNING: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required to get the database. Skipping." >&2
  return
fi

# if ! type "mysql" > /dev/null; then
#   echo "Lets install mysql";
#   apt-get update -y && apt-get install mysql-client -y
# fi

read -p "WARNING: Hey, look at here! \
Would you like to download the phila.gov database inside the db/ folder? [Y/n]" download
echo #Emtpy line, you know.

if [[ $download =~ ^[Yy]$ ]]; then
    if [ -f "/db/$PHILA_DB_FILE" ]; then
        read -p "WARNING: Oh my gosh! \
I found a current.sql file inside the db folder, \
would you like to override it? [Y/n]" rewriteit
        echo #Emtpy line, you know.
        download=$rewriteit
    fi
fi

if [[ $download =~ ^[Yy]$ ]]; then
    echo "I hope you know what you are doing... =)"
    echo "Deleting current.sql"
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

maxcounter=12
counter=1
while ! wp db check --allow-root | grep -q "Success"; do
    sleep 2
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "WARNING: We have been waiting for MySQL too long already; failing."
        break
    fi;
    echo "WARNING: Let's try to connect to database again"
done

if [ -f "/db/$PHILA_DB_FILE" ]; then
    read -p "WARNING: Now importing! \
Would you like to import the current.sql file into your database? [Y/n]" import
    echo    # (optional) move to a new line
    if [[ $import =~ ^[Yy]$ ]]; then
        echo "Installing DB..."
        wp db import --allow-root --debug=bootstrap "/db/$PHILA_DB_FILE"
    fi
fi

popd

# /entrypoint.sh "$@"