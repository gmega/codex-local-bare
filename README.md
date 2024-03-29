# Running a Codex Network Locally

This repo contains a set of rather unpolished, Linux/GNOME-specific scripts for 
launching a Geth PoA + Codex network locally (running bare, no containers) and
seeing each process in its own terminal. This is thouroughly insecure and naive,
and should be used only for reference or for playing around with Codex.

It assumes that you have:

* [downloaded and compiled Codex somewhere](https://github.com/codex-storage/nim-codex/);
* installed [geth](https://github.com/ethereum/go-ethereum) and made the `geth` binary accessible from the global path;
* have the latest version of [NodeJS](https://nodejs.org/en) installed.

Start by cloning this repo, then:

```bash
export CODEX_SOURCE_HOME="<place where you cloned the Codex repo>"

npm install # install JS deps

./scripts/init-geth-network.sh
./scripts/start-geth-network.sh

# wait until 256 blocks are minted in the Geth network, which should take
# 256/60 ~ 4m30s

./scripts/init-marketplace.sh
./scripts/start-codex-network.sh
```

and, assuming everything works, you're done. :-)