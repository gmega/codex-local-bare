#!/usr/bin/env bash
set -e

source "$(dirname $0)/common.sh"

cd "${NETWORK_BASE}"

echo "Cloning marketplace contracts."

if [ -d "codex-contracts-eth" ]; then
  rm -rf codex-contracts-eth
fi

echo "Deploying contracts."

git clone https://github.com/codex-storage/codex-contracts-eth

cd codex-contracts-eth
export DISTTEST_NETWORK_URL=http://localhost:8545
npm install
npx hardhat deploy --network codexdisttestnetwork

echo "Creating accounts for storage provider and client."

cd ../../.. # back to package root

# Provisions accounts for 3 storage nodes, and 1 client node.
create_account "storage1"
seed_account "storage1"

create_account "storage2"
seed_account "storage2"

create_account "storage3"
seed_account "storage3"

create_account "client"
seed_account "client"

echo "All good."