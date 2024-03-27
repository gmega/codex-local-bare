#!/usr/bin/env bash
set -e

NETWORK_ID=${NETWORK_ID:-"12345"}
NETWORK_BASE="networks/${NETWORK_ID}"

spawn () {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    gnome-terminal -- "$@"
  else
    echo "Don't know how to spawn a new terminal on ${OSTYPE}"
  fi
}

SIGNER_ACCOUNT=$(cat "./${NETWORK_BASE}/network.json" | jq '.alloc | keys[0]' --raw-output)

echo "Signer account is: ${SIGNER_ACCOUNT}"

rm -rf .fake-passfile
touch .fake-passfile

spawn geth\
  --datadir "./${NETWORK_BASE}/data1"\
  --networkid 12345\
  --unlock "${SIGNER_ACCOUNT}"\
  --password .fake-passfile\
  --nat extip:127.0.0.1\
  --netrestrict 127.0.0.0/24\
  --mine\
  --miner.etherbase ${SIGNER_ACCOUNT}\
  --http\
  --allow-insecure-unlock

sleep 3

BOOTSTRAP_ENR=$(geth attach --exec=admin.nodeInfo.enr "./${NETWORK_BASE}/data1/geth.ipc" | sed 's/"//g')

echo "Bootstrap ENR is ${BOOTSTRAP_ENR}"

spawn geth\
  --datadir "./${NETWORK_BASE}/data2"\
  --networkid 12345\
  --bootnodes "${BOOTSTRAP_ENR}"\
  --netrestrict 127.0.0.0/24\
  --port 30305\
  --authrpc.port 8036\
  --http\
  --http.port 8546
