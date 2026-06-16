#!/bin/bash

set -e

if [ -z "$WALLET_ADDRESS" ]; then
    echo "ERROR: WALLET_ADDRESS environment variable is required"
    exit 1
fi

# install miner if not already installed
if [ ! -f "$HOME/moneroocean/miner.sh" ]; then
    echo "Installing moneroocean miner..."
    curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s "$WALLET_ADDRESS"
fi

# deactivate auto-start in .profile
sed -i 's|/root/moneroocean/miner.sh|#/root/moneroocean/miner.sh|g' "$HOME/.profile"

# set max threads hint
sed -i 's|"max-threads-hint": [0-9]*,|"max-threads-hint": '"$MAX_THREADS_HINT"',|g' "$HOME/moneroocean/config.json"

# msr tweak
./randomx_boost.sh

# start mining
"$HOME/moneroocean/miner.sh" &

# start cron for metrics
cron -f
