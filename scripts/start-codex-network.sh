#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

if [ -z "${CODEX_SOURCE_HOME}" ]; then
  echo "Please set CODEX_SOURCE_HOME to the path of the Codex source repository."
  exit 1
fi

echo "Starting Codex storage provider."
read_marketplace_address

PROVER_ASSETS_HOME="${CODEX_SOURCE_HOME}/tests/circuits/fixtures/"

start_codex_storage_node () {
  if [ -z "$1" ]; then
    echo "Please provide a port offset."
    exit 1
  fi

  local port_offset=$1
  local storage_key="${PROJECT_ROOT}/${NETWORK_BASE}/storage${1}-key"

  local listen_port=$((8080 + port_offset))
  local api_port=$((8000 + port_offset))
  local disc_port=$((8090 + port_offset))

  echo "* Starting Codex storage node ${1} (API port is ${api_port})"

  spawn "${PROJECT_ROOT}/scripts/tee.sh" "${NETWORK_BASE_FULL}/codex${1}.log"\
    ${CODEX_SOURCE_HOME}/build/codex ${bootstrap}\
    --data-dir="./codex${1}"\
    --listen-addrs=/ip4/0.0.0.0/tcp/${listen_port}\
    --api-port=${api_port}\
    --disc-port=${disc_port}\
    persistence\
    --eth-provider=http://localhost:8545\
    --eth-private-key="${NETWORK_BASE_FULL}/storage${1}-key"\
    --marketplace-address="${MARKETPLACE_ADDRESS}"\
    --validator\
    --validator-max-slots=1000\
    prover\
    --circom-r1cs="${PROVER_ASSETS_HOME}/proof_main.r1cs"\
    --circom-wasm="${PROVER_ASSETS_HOME}/proof_main.wasm"\
    --circom-zkey="${PROVER_ASSETS_HOME}/proof_main.zkey"

  if [ -z "${bootstrap}" ]; then
    # Yes, this is totally broken.
    sleep 5
    bootstrap_spr=$(curl -s localhost:${api_port}/api/codex/v1/debug/info | jq .spr --raw-output)
    export bootstrap="--bootstrap-node=${bootstrap_spr}"
    echo " * Boostrap SPR is ${bootstrap_spr}"
  fi
}

cd ${NETWORK_BASE}

start_codex_storage_node 1
start_codex_storage_node 2
start_codex_storage_node 3

echo "* Starting Codex client node (API port is 8000)"

spawn ${CODEX_SOURCE_HOME}/build/codex ${bootstrap}\
  --data-dir="./codex2"\
  --listen-addrs=/ip4/0.0.0.0/tcp/8082\
  --api-port=8000\
  --disc-port=8090\
  persistence\
  --eth-provider=http://localhost:8545\
  --eth-private-key="${PROJECT_ROOT}/${NETWORK_BASE}/client-key"\
  --marketplace-address="${MARKETPLACE_ADDRESS}"\
  --validator\
  --validator-max-slots=1000

cd ../..
