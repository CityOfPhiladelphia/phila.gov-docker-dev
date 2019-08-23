#!/bin/bash
CMD=$1
_dir="$(dirname "$0")"

source "$_dir/philagov.sh" "$CMD"
source "$_dir/wp-config.sh" "$CMD"
source "$_dir/private-plugins.sh" "$CMD"
source "$_dir/gen-cert.sh" "$CMD"
source "$_dir/node.sh" "$CMD"
# source "$_dir/fix-wp-permissions.sh" "$CMD"
source "$_dir/mysql-config.sh" "$CMD"

/usr/bin/supervisord