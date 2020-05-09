#!/bin/bash
CONFIGS=("config.yml")
CONFIG_YAML_URL=""

function move_and_backup {
  cp -v /tmp/"${1}".remote /srv/minecraft/"${1}" 2>&1
  mv -v /tmp/"${1}".remote /tmp/"${1}".remote.bak 2>&1
  if [ $? != 0 ]; then
    echo "ERROR: move_and_backup failed" 2>&1
    exit 2
  fi
}

for CONFIG in "${CONFIGS[@]}"; do
  case "${CONFIG}" in
  "config.yml" ) CURRENT_URL="${CONFIG_YAML_URL}" ;;
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
    if [ ! -e /tmp/"${CONFIG}".remote ]; then
      if [ "${CONFIG}" == "server.properties" ]; then
        echo "Copy default properties file" 2>&1
        cp /tmp/server.properties.default /srv/minecraft/server.properties
        if [ $? != 0 ]; then
          echo "ERROR: unable to write server.properties to /srv. Please make sure directory is attached." 2>&1
          exit 2
        fi
      fi
    else
      move_and_backup "${CONFIG}"
    fi
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