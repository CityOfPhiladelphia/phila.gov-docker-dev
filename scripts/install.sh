#!/bin/bash
#
# Please run as root.
# Usage: bash findport.sh 3000 100
#

image_name="philagov"
image_version="latest"

if [[ "$(docker images -q $image_name:$image_version 2> /dev/null)" == "" ]]; then
  echo "Please, create the image running this command first: 'docker build https://github.com/CityOfPhiladelphia/phila.gov-docker-dev.git -t $image_name:$image_version'"
  exit 1
fi

BASE=19107
INCREMENT=10

port=$BASE
isfree=$(lsof -nP -i4TCP:$port | grep LISTEN)

while [[ -n "$isfree" ]]; do
  port=$[port+INCREMENT]
  isfree=$(lsof -nP -i4TCP:$port | grep LISTEN)
done

echo "Web Port: $port"
echo "Name: philagov-$port"

export INSTALATION_PORT=$port
export INSTALATION_NAME="philagov-$port"
export PHILAGOV_IMAGE="$image_name:$image_version"

COMMAND="docker-compose run --service-ports --name $INSTALATION_NAME philagov"
echo "$COMMAND"

$COMMAND