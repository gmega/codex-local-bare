# Running a Codex Network Locally

This repo contains a set of rather unpolished, Linux/GNOME-specific scripts for 
launching a Geth PoA + Codex network locally (running bare, no containers) and
seeing each process in its own terminal. This is thouroughly insecure and naive,
and should be used only for reference or for playing around with Codex.

It assumes you have [downloaded and compiled Codex already](https://github.com/codex-storage/nim-codex/),
and that the `geth` binary is accessible from the global path.

```bash
export CODEX_SOURCE_HOME="<place where you cloned the Codex repo>"

./scripts/init-geth-network.sh
./scripts/start-geth-network.sh

# wait until 256 blocks are minted in the Geth network, which should take
# 256/60 ~ 4m27s

./scripts/init-marketplace.sh
./scripts/start-codex-network.sh
```

and, assuming everything works, you're done. :-)