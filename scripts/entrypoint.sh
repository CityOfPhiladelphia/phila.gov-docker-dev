#!/bin/bash
CMD=$1
_dir="$(dirname "$0")"

source "$_dir/philagov.sh" "$CMD"
source "$_dir/wp-config.sh" "$CMD"
source "$_dir/private-plugins.sh" "$CMD"
source "$_dir/gen-cert.sh" "$CMD"

# Install node dependencies
# pushd /var/www/html/wp-content/themes/phila.gov-theme
# npm install

# # Run node build scripts
# case "$CMD" in
#   "dev" )
#     npm run dev:build
#     ;;
#   "start" )
#     npm run build
#     ;;
#   * )
#     exec $CMD ${@:2}
#     ;;
# esac

# popd

# source "$_dir/fix-wp-permissions.sh" "$CMD"
source "$_dir/mysql-config.sh" "$CMD"

/usr/bin/supervisord