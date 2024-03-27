#!/usr/bin/env bash
set -e

NETWORK_ID=${NETWORK_ID:-"12345"}
NETWORK_BASE="networks/${NETWORK_ID}"
CODEX_BINARY=${CODEX_BINARY:-""}

if [ -z "${CODEX_BINARY}" ]; then
  echo "Please set CODEX_BINARY to the path of the Codex binary."
  exit 1
fi

echo "Starting Codex storage provider."

SIGNER_ACCOUNT=$(cat "${NETWORK_BASE}/signer-account")
SIGNER_PRIVATE_KEY=$(./scripts/geth-accounts.js "${SIGNER_ACCOUNT}")
MARKETPLACE_ADDRESS=$(cat "${NETWORK_BASE}/codex-contracts-eth/deployments/codexdisttestnetwork/CodexMarketplace.json" | jq '.address' --raw-output)

cd ${NETWORK_BASE}

codex persistence\
  --eth-provider=http://localhost:8545\
  --eth-account=$(cat "${NETWORK_BASE}/storage-account")\
  --eth-private-key=<(echo "${SIGNER_PRIVATE_KEY}")\
  --marketplace-address="${MARKETPLACE_ADDRESS}"\
  --validator\
  --validator-max-slots=1000
  