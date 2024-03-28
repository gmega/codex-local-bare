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

create_account "storage"
create_account "client"

read_account "client"
read_account "signer"

echo "Minting tokens for client (${CLIENT_ACCOUNT})."

./scripts/mint-tokens.js ./${NETWORK_BASE}/codex-contracts-eth/deployments/codexdisttestnetwork/TestToken.json ${SIGNER_ACCOUNT} ${CLIENT_ACCOUNT} 100000

echo "All good."