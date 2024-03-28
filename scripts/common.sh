# -----------------------------------------------------------------------------
# These should be defined by the user.
export NETWORK_ID=${NETWORK_ID:-"12345"}
export CODEX_SOURCE_HOME=${CODEX_SOURCE_HOME:-""}
# -----------------------------------------------------------------------------
export CODEX_LOG_LEVEL="TRACE;warn:discv5,providers,manager,cache;warn:libp2p,multistream,switch,transport,tcptransport,semaphore,asyncstreamwrapper,lpstream,mplex,mplexchannel,noise,bufferstream,mplexcoder,secure,chronosstream,connection,connmanager,websock,ws-session,dialer,muxedupgrade,upgrade,identify"
export NETWORK_BASE="networks/${NETWORK_ID}"

# Opens a terminal with a command running in it. OS-specific.
spawn () {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    gnome-terminal -- "$@"
  else
    echo "Don't know how to spawn a new terminal on ${OSTYPE}"
  fi
}

create_geth_account () {
  if [ -z "$1" ]; then
    echo "Please provide an account name."
    exit 1
  fi

  geth account new --datadir "./${NETWORK_BASE}/data1" --password <(echo "") | grep -o -e '0x[A-Za-z0-9]*' > "./${NETWORK_BASE}/${1}-account"
}

read_account () {
  if [ -z "$1" ]; then
    echo "Please provide an account name."
    exit 1
  fi
  var_value=$(cat "./${NETWORK_BASE}/${1}-account")
  declare -g "${1^^}_ACCOUNT"="${var_value}"
}

# Reads the address of the marketplace contract from the hardhat deployment.
read_marketplace_address () {
  MARKETPLACE_ADDRESS=$(cat "${NETWORK_BASE}/codex-contracts-eth/deployments/codexdisttestnetwork/Marketplace.json" | jq '.address' --raw-output)
}
