# -----------------------------------------------------------------------------
# These should be defined by the user.
export NETWORK_ID=${NETWORK_ID:-"12345"}
export CODEX_SOURCE_HOME=${CODEX_SOURCE_HOME:-""}
# -----------------------------------------------------------------------------
# export CODEX_LOG_LEVEL="INFO;trace:codex,marketplace"
export NETWORK_BASE="networks/${NETWORK_ID}"
export PROJECT_ROOT=${PWD}
export NETWORK_BASE_FULL="${PROJECT_ROOT}/${NETWORK_BASE}"
export CONTRACT_DEPLOY_FULL="${NETWORK_BASE_FULL}/codex-contracts-eth/deployments/codexdisttestnetwork"

# Opens a terminal with a command running in it. OS-specific.
spawn () {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    gnome-terminal -- "$@"
  else
    echo "Don't know how to spawn a new terminal on ${OSTYPE}"
  fi
}

create_account () {
  # Creates an account and stores the address and key in files.
  if [ -z "$1" ]; then
    echo "Please provide an account name."
    exit 1
  fi

  local ACCOUNT=$(geth account new --datadir "./${NETWORK_BASE}/data1" --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*')
  echo $ACCOUNT > "./${NETWORK_BASE}/${1}-account"
  ./scripts/geth-accounts.js $ACCOUNT > "./${NETWORK_BASE}/${1}-key"
  chmod 600 "./${NETWORK_BASE}/${1}-key"
}

seed_account() {
  # Puts ETH and CDX into the account so it can operate in the Codex marketplace.
  if [ -z "$1" ]; then
    echo "Please provide an account name."
    exit 1
  fi
  read_account "signer"
  read_account "${1}"
  echo "Minting tokens for client (${1})."
  ./scripts/mint-tokens.js "${CONTRACT_DEPLOY_FULL}/TestToken.json" ${SIGNER_ACCOUNT} ${account_read} 100000000000
}

read_account () {
  if [ -z "$1" ]; then
    echo "Please provide an account name."
    exit 1
  fi
  var_value=$(cat "./${NETWORK_BASE}/${1}-account")
  declare -g "${1^^}_ACCOUNT"="${var_value}"
  account_read="${var_value}"
}

# Reads the address of the marketplace contract from the hardhat deployment.
read_marketplace_address () {
  MARKETPLACE_ADDRESS=$(cat "${NETWORK_BASE}/codex-contracts-eth/deployments/codexdisttestnetwork/Marketplace.json" | jq '.address' --raw-output)
}
