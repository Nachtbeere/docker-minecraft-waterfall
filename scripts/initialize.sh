#!/bin/bash
CONFIGS=("config.yml" "server-icon.png")
CONFIG_YAML_URL=""
SERVER_ICON_URL=""

function move_and_backup {
  cp -v /tmp/"${1}".remote /srv/minecraft/"${1}" 2>&1
  mv -v /tmp/"${1}".remote /tmp/"${1}".remote.bak 2>&1
  if [ $? != 0 ]; then
    echo "ERROR: move_and_backup failed" 2>&1
  fi
}

for CONFIG in "${CONFIGS[@]}"; do
  case "${CONFIG}" in
  "config.yml" ) CURRENT_URL="${CONFIG_YAML_URL}" ;;
  "server-icon.png") CURRENT_URL="${SERVER_ICON_URL}" ;;
  esac
  if [ "${CURRENT_URL}" != "" ]; then
    echo "Fetch config file from server" 2>&1
    curl -L --output /tmp/"${CONFIG}".remote -H "Cache-Control: no-cache" "${CURRENT_URL}" 2>&1
    if [ $? != 0 ]; then
      echo "ERROR: unable to fetch ${CONFIG}" 2>&1
      exit 2
    fi
  fi
  if [ ! -e /srv/minecraft/"${CONFIG}" ]; then
      move_and_backup "${CONFIG}"
  else
    if [ -f /tmp/"${CONFIG}".remote ]; then
      if ! cmp -s /srv/minecraft/"${CONFIG}" /tmp/"${CONFIG}".remote; then
        echo "MESSAGE: ${CONFIG} has changed from remote." 2>&1
        move_and_backup "${CONFIG}"
        echo "MESSAGE: ${CONFIG} is now up to date." 2>&1
      fi
    fi
  fi
done