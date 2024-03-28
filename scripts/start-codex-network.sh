#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

if [ -z "${CODEX_SOURCE_HOME}" ]; then
  echo "Please set CODEX_SOURCE_HOME to the path of the Codex source repository."
  exit 1
fi

echo "Starting Codex storage provider."

read_account "storage"
read_account "client"

read_marketplace_address

PROVER_ASSETS_HOME="${CODEX_SOURCE_HOME}/tests/circuits/fixtures/"
STORAGE_PRIVATE_KEY=$(./scripts/geth-accounts.js "${STORAGE_ACCOUNT}")
CLIENT_PRIVATE_KEY=$(./scripts/geth-accounts.js "${CLIENT_ACCOUNT}")

cd ${NETWORK_BASE}

# Storage node.
spawn ${CODEX_SOURCE_HOME}/build/codex\
  --data-dir="./codex1"\
  --listen-addrs=/ip4/0.0.0.0/tcp/8081\
  --api-port=8001\
  --disc-port=8091\
  persistence\
  --eth-provider=http://localhost:8545\
  --eth-account="${STORAGE_ACCOUNT}"\
  --eth-private-key=<(echo "${STORAGE_PRIVATE_KEY}")\
  --marketplace-address="${MARKETPLACE_ADDRESS}"\
  --validator\
  --validator-max-slots=1000\
  prover\
  --circom-r1cs="${PROVER_ASSETS_HOME}/proof_main.r1cs"\
  --circom-wasm="${PROVER_ASSETS_HOME}/proof_main.wasm"\
  --circom-zkey="${PROVER_ASSETS_HOME}/proof_main.zkey"

# Yes, this is totally broken.
sleep 5

BOOTSTRAP_SPR=$(curl -s localhost:8001/api/codex/v1/debug/info | jq .spr --raw-output)

echo "Codex storage provider is up and running with SPR ${BOOTSTRAP_SPR}."

spawn ${CODEX_SOURCE_HOME}/build/codex\
  --data-dir="./codex2"\
  --listen-addrs=/ip4/0.0.0.0/tcp/8082\
  --api-port=8002\
  --disc-port=8092\
  --bootstrap-node="${BOOTSTRAP_SPR}"\
  persistence\
  --eth-provider=http://localhost:8545\
  --eth-account="${CLIENT_ACCOUNT}"\
  --eth-private-key=<(echo "${CLIENT_PRIVATE_KEY}")\
  --marketplace-address="${MARKETPLACE_ADDRESS}"\
  --validator\
  --validator-max-slots=1000

cd ../..
