#!/bin/bash

if [ ! "$AWS_ACCESS_KEY_ID" ] || [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required to install private plugins. Skipping." >&2
  return
fi

echo "Installing private plugins"

plugins="mb-admin-columns-1.3.0.zip
mb-revision-1.1.1.zip
meta-box-columns-1.2.3.zip
meta-box-conditional-logic-1.5.7.zip
meta-box-group-1.2.16.zip
meta-box-include-exclude-1.0.10.zip
meta-box-tabs-1.1.0.zip
meta-box-tooltip-1.1.1.zip
mb-term-meta-1.2.3.zip
meta-box-updater-1.3.0.zip
wpfront-user-role-editor-personal-pro-2.14.1.zip"

pushd /var/www/html/wp-content/plugins

for plugin in $plugins; do
  echo "... $plugin"
  s3_url="s3://$PHILA_PLUGINS_BUCKET/$plugin"
  aws s3 cp "$s3_url" ./
  unzip -o -q "$plugin"
  rm "$plugin"
done

popd