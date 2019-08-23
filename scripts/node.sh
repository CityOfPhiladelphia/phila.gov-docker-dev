#!/bin/bash

CMD=$1

BASE_PATH="/var/www/html/wp-content/themes/phila.gov-theme"

if [ -f "$BASE_PATH/css/styles.css" ] && [ -f "$BASE_PATH/js/phila-scripts.js" ]; then
  printf $'\e[33mIt looks like I do not need tu run \e[36mNPM\e[33m, Skipping...\e[0m\n'
  return;
fi


# # Install node dependencies
pushd "$BASE_PATH"

npm install

# Run node build scripts
case "$CMD" in
  "dev" )
    npm run dev:build
    ;;
  "start" )
    npm run build
    ;;
  * )
    exec $CMD ${@:2}
    ;;
esac

popd