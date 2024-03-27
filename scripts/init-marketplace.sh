#!/usr/bin/env bash
set -e

NETWORK_ID=${NETWORK_ID:-"12345"}
NETWORK_BASE="networks/${NETWORK_ID}"

cd "${NETWORK_BASE}"

echo "Cloning marketplace contracts."

if [ -d "codex-contracts-eth" ]; then
  rm -rf codex-contracts-eth
fi

git clone https://github.com/codex-storage/codex-contracts-eth

echo "Deploying contracts."
cd codex-contracts-eth

export DISTTEST_NETWORK_URL=http://localhost:8545
npm install
npx hardhat deploy --network codexdisttestnetwork

cd ..

echo "Creating accounts for storage provider and client."
geth account new --datadir "./data1" --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*'  >> ./storage-account 
geth account new --datadir "./data1" --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*'  >> ./client-account

echo "Minting tokens for client."
../../scripts/mint-tokens.js ./codex-contracts-eth/deployments/codexdisttestnetwork/TestToken.json $(cat ./client-account) 100000

echo "All good."