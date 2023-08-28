#!/usr/bin/env bash

set -e

if [ -z "$UINTENT_DEVICE_IP" ]; then
      echo "UINTENT_DEVICE_IP is empty"
      exit 1
fi

# remove brackets from IPv6 address if there are any
UINTENT_DEVICE_IP_NB=${UINTENT_DEVICE_IP#[}
UINTENT_DEVICE_IP_NB=${UINTENT_DEVICE_IP_NB%]}

echo "deleting old config profiles"
ssh "root@${UINTENT_DEVICE_IP_NB}" "rm -f /lib/uintent/config/profile/*"

echo "pushing new config profiles"
scp -r -O "${UINTENT_CONFIG_DIR}/profile/" "root@${UINTENT_DEVICE_IP}":/lib/uintent/config/

echo "starting reconfigure"
ssh "root@${UINTENT_DEVICE_IP_NB}" "reconfigure"
