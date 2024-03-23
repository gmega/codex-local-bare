#!/usr/bin/env bash
set -e

spawn () {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    gnome-terminal -- "$@"
  else
    echo "Don't know how to spawn a new terminal on ${OSTYPE}"
  fi
}

SIGNER_ACCOUNT=$(geth account new --datadir ./data1 --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*' | sed 's/0x//')

cat network.json.template | sed "s/SIGNER_ACCOUNT/$SIGNER_ACCOUNT/g" > network.json

echo "Signer account is 0x${SIGNER_ACCOUNT}"

geth init --datadir ./data1 ./network.json

spawn geth\
  --datadir data1\
  --networkid 12345\
  --unlock "${SIGNER_ACCOUNT}"\
  --password <(echo "")\
  --nat extip:127.0.0.1\
  --netrestrict 127.0.0.0/24\
  --mine\
  --miner.etherbase ${SIGNER_ACCOUNT}\
  --http\
  --allow-insecure-unlock

sleep 1

BOOTSTRAP_ENR=$(geth attach --exec=admin.nodeInfo.enr ./data1/geth.ipc | sed 's/"//g')

echo "Bootstrap ENR is ${BOOTSTRAP_ENR}"

geth init --datadir ./data2 ./network.json

spawn geth\
  --datadir data2\
  --networkid 12345\
  --bootnodes "${BOOTSTRAP_ENR}"\
  --netrestrict 127.0.0.0/24\
  --port 30305\
  --authrpc.port 8036\
  --http\
  --http.port 8546
  