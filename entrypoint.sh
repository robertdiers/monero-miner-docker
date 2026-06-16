#!/bin/bash

set -e

if [ -z "$WALLET_ADDRESS" ]; then
    echo "ERROR: WALLET_ADDRESS environment variable is required"
    exit 1
fi

echo "Running randomx_boost..."
./randomx_boost.sh

# install miner if not already installed
if [ ! -f "$HOME/moneroocean/miner.sh" ]; then
    echo "Installing moneroocean miner..."
    curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s "$WALLET_ADDRESS"
fi

echo "Setting max threads hint to $MAX_THREADS_HINT..."
sed -i 's|"max-threads-hint": [0-9]*,|"max-threads-hint": '"$MAX_THREADS_HINT"',|g' "$HOME/moneroocean/config.json"

echo "Starting cron for metrics..."
cron -f
