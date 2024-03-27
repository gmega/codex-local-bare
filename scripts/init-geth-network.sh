#!/usr/bin/env bash
set -e

NETWORK_ID=${NETWORK_ID:-"12345"}
NETWORK_BASE="networks/${NETWORK_ID}"

mkdir -p "${NETWORK_BASE}"

SIGNER_ACCOUNT=$(geth account new --datadir "./${NETWORK_BASE}/data1" --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*' | sed 's/0x//')

cat network.json.template | sed "s/SIGNER_ACCOUNT/$SIGNER_ACCOUNT/g;s/NETWORK_ID/$NETWORK_ID/g" > "./${NETWORK_BASE}/network.json"

echo "Signer account is 0x${SIGNER_ACCOUNT}"

echo "${SIGNER_ACCOUNT}" > "./${NETWORK_BASE}/signer-account"

geth init --datadir ./${NETWORK_BASE}/data1 ./${NETWORK_BASE}/network.json
geth init --datadir ./${NETWORK_BASE}/data2 ./${NETWORK_BASE}/network.json
