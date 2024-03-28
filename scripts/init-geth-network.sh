#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

mkdir -p "${NETWORK_BASE}"

create_account "signer"
read_account "signer"

echo "Signer account is 0x${SIGNER_ACCOUNT}"

SIGNER_ACCOUNT_RAW=$(echo "${SIGNER_ACCOUNT}" | sed 's/0x//g')

cat network.json.template | sed "s/SIGNER_ACCOUNT/$SIGNER_ACCOUNT_RAW/g;s/NETWORK_ID/$NETWORK_ID/g" > "./${NETWORK_BASE}/network.json"

geth init --datadir ./${NETWORK_BASE}/data1 ./${NETWORK_BASE}/network.json
geth init --datadir ./${NETWORK_BASE}/data2 ./${NETWORK_BASE}/network.json
