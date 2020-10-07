#!/bin/bash

DESMOS_VERSION="v0.12.3"
MONIKER=$(cat ~/desmos/acc_name.txt)
BIN_PATH="$HOME/go/bin"
PERSISTENT_PEERS="40aa34719d0cd46a97d78dbcc798b3b2c51ce6e9@167.86.118.162:26656,4d9f7ac4b62b4545322dc39fc09bc2ab50e60590@78.47.152.196:26656"

echo "-> INSTALL REQUIREMENTS"
apt update \
  && apt install -y zip unzip make gcc build-essential jq

echo "--> INSTALL GO"
curl -s https://gist.githubusercontent.com/c29r3/3130b5cd51c4a94f897cc58443890c28/raw/4269d88af953d60507c54483fa09eeb26dd1f869/install_golang.sh | bash

# echo "---> COMPILE BINARY FILES"
# mkdir ~/desmos; \
#   cd ~/desmos; \
#   curl -s -LO https://github.com/desmos-labs/desmos/archive/$DESMOS_VERSION.zip > $DESMOS_VERSION.zip; \
#   unzip -q -o $DESMOS_VERSION.zip; \
#   cd desmos-*; \
#   make install; \
#   $BIN_PATH/desmosd version --long

echo "Downloading binary files"
mkdir -p $HOME/go/bin
wget -q https://github.com/c29r3/desmos-utils/releases/download/v0.12.3/desmos-v0.12.3.tar.gz
echo "Extracting binary files"
tar xf desmos-v0.12.3.tar.gz -C $HOME/go/bin

echo "----> INIT CONFIG FILE"
$BIN_PATH/desmosd init $MONIKER --chain-id morpheus-10000

echo "-----> DOWNLOAD GENESIS FILE"
curl -s https://raw.githubusercontent.com/desmos-labs/morpheus/master/genesis.json | jq . > $HOME/.desmosd/config/genesis.json


echo "Change default prof_laddr 6060 --> 6081"
sed -i 's|prof_laddr = "localhost:6060"|prof_laddr = "localhost:6081"|g' $HOME/.desmosd/config/config.toml

echo "Setting up persistent_peers in config file"
sed -i "s|persistent_peers = \"\"|persistent_peers = \"$PERSISTENT_PEERS\"|g" $HOME/.desmosd/config/config.toml

$BIN_PATH/desmoscli config trust-node true
$BIN_PATH/desmoscli config keyring-backend test

echo "Generating new key"
echo "yes\n" | $BIN_PATH/desmoscli keys add desmos --keyring-backend test -o json &> $HOME/desmos/desmos_key.json

cat $HOME/desmos/desmos_key.json | jq -r .

echo "------> Creating systemd unit desmos.service"
tee /etc/systemd/system/desmosd.service > /dev/null <<EOF  
[Unit]
Description=Desmosd Full Node
After=network-online.target
[Service]
User=root
ExecStart=/root/go/bin/desmosd start
Restart=always
RestartSec=3
LimitNOFILE=150000
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable desmosd
systemctl start desmosd
