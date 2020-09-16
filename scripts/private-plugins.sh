#!/bin/bash

if [ ! "$AWS_ACCESS_KEY_ID" ] || [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Warning: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required to install private plugins. Skipping." >&2
  return
fi

printf $'\e[33mInstalling private plugins\e[0m\n'

plugins="mb-admin-columns-1.5.0.zip
mb-revision-1.3.3.zip
mb-settings-page-2.1.3.zip
mb-term-meta-1.2.9.zip
meta-box-columns-1.2.6.zip
meta-box-conditional-logic-1.6.13.zip
meta-box-group-1.3.11.zip
meta-box-include-exclude-1.0.11.zip
meta-box-tabs-1.1.8.zip
meta-box-tooltip-1.1.3.zip
wpfront-user-role-editor-personal-pro-2.14.5.zip"

pushd /var/www/html/wp-content/plugins

for plugin in $plugins; do
  # If a plugin already exists, we do not need to install it.
  printf $'... \e[36m%s\e[0m\n' $plugin
  if ! grep -q "$plugin" ~/.plugins; then    
    s3_url="s3://$PHILA_PLUGINS_BUCKET/$plugin"
    aws s3 cp "$s3_url" ./
    unzip -o -q "$plugin"
    rm "$plugin"
    echo "$plugin" >> ~/.plugins
  else
    printf $'\e[33mPlugin already exists, skipping...\e[0m\n'
  fi
done

popd
