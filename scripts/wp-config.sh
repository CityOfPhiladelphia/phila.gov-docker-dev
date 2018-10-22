#!/bin/bash
CMD=$1
[ $CMD == "dev" ] && DEBUG=true || DEBUG=false

echo "Writing wp-config.php"

# Remove existing config if exists
rm -f wp-config.php

wp config create \
  --path=/var/www/html \
  --dbhost="$WORDPRESS_DB_HOST" \
  --dbname="$WORDPRESS_DB_NAME" \
  --dbuser="$WORDPRESS_DB_USER" \
  --dbpass="$WORDPRESS_DB_PASSWORD" \
  --skip-check \
  --allow-root \
  --force \
  --extra-php <<PHP
/** Debug in development environment */
define('WP_DEBUG', $DEBUG );
define('WP_DEBUG_LOG', $DEBUG );
define('WP_DEBUG_DISPLAY', $DEBUG );

/** WP_SITEURL overrides DB to set WP core address */
define('WP_SITEURL', 'https://$DOMAIN');

/** WP_HOME overrides DB to set public site address */
define('WP_HOME', 'https://$DOMAIN'); 

/** For AWS and S3 usage */
define('AWS_ACCESS_KEY_ID', '$AWS_ACCESS_KEY_ID');
define('AWS_SECRET_ACCESS_KEY', '$AWS_SECRET_ACCESS_KEY');

define( 'WPOS3_SETTINGS', serialize( array(
  'bucket' => '$PHILA_MEDIA_BUCKET',
  'cloudfront' => '$DOMAIN'
) ) );

/** For Swiftype search */
define('SWIFTYPE_ENGINE', '$SWIFTYPE_ENGINE');

/** For Google Calendar Archives */
define('GOOGLE_CALENDAR', '$GOOGLE_CALENDAR');

/** Don't let stuff sit around too long */
define('EMPTY_TRASH_DAYS', 7);

/** Disable WP cron, it runs on every page load! */
define('DISABLE_WP_CRON', true);

/** We manually update WP, so disable auto updates */
define('WP_AUTO_UPDATE_CORE', false);

/** https://wordpress.org/support/topic/problem-after-the-recent-update */
define('FS_METHOD', 'direct');
PHP
