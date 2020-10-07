####################################
## Variables
####################################
MONIKER=$1
if [ -z "$MONIKER" ]; then
  echo "Validator moniker not given. Please specify it as the first argument"
  exit 0
fi

USER=$(id -u -n)


####################################
## Setup environmental variables
####################################
echo "===> Setting up environmental variables"

if [ -z "$GOPATH" ]; then
  echo "GOPATH environmental variable not set" >> ~/.profile
  exit 0
fi

if [ -z "$GOBIN" ]; then
    echo "export GOBIN=$GOPATH/bin" >> ~/.profile
    source ~/.profile
fi

if [ -z "$DAEMON_NAME" ]; then
    echo " " >> ~/.profile
    echo "# Setup Cosmovisor" >> ~/.profile
    echo "export DAEMON_NAME=desmosd" >> ~/.profile
    echo "export DAEMON_HOME=$HOME/.desmosd" >> ~/.profile
    echo "export DAEMON_RESTART_AFTER_UPGRADE=on" >> ~/.profile
    source ~/.profile
fi

echo "===> Completed environmental variables setup"
echo ""

####################################
## Setup Cosmovisor
####################################
echo "===> Setting up Cosmovisor"

echo "=====> Downloading Cosmovisor"
# Download Cosmovisor
git clone https://github.com/cosmos/cosmos-sdk.git ~/cosmos
cd ~/cosmos/cosmovisor
make cosmovisor
cp cosmovisor $GOBIN/cosmovisor
cd ~

# Prepare Cosmovisor
echo "=====> Installing up Cosmovisor"
wget -O desmosd-cosmovisor.zip http://ipfs.io/ipfs/QmfVPHGPEimn7BKQo5JNeyiPtjbkYWqfnEvUnqfAVQapUe
sudo rm -rf ~/.desmosd
mkdir -p ~/.desmosd
unzip desmosd-cosmovisor.zip -d ~/.desmosd

echo "===> Completed Cosmovisor setup"
echo ""

####################################
## Setup Desmos
####################################
echo "===> Setting up Desmos"

# Setup desmosd to use Cosmovisor
echo 'alias desmosd=~/.desmosd/cosmovisor/current/bin/desmosd' >> ~/.bashrc
echo 'alias desmoscli=~/.desmosd/cosmovisor/current/bin/desmoscli' >> ~/.bashrc
source ~/.bashrc

# Setup the chain
echo "=====> Initializing the chain"
$HOME/.desmosd/cosmovisor/genesis/bin/desmosd init $MONIKER

# Download the genesis file
echo "=====> Downloading the genesis file"
curl -s https://raw.githubusercontent.com/desmos-labs/morpheus/master/genesis.json > $HOME/.desmosd/config/genesis.json

# Setup the persistent peers
echo "=====> Setting persistent peers"
sed -i -e 's/persistent_peers = ""/persistent_peers = "7fed5624ca577eb0333d3631b5e4f16ba1736979@54.180.98.75:26656,5077b7964d71d8758f7fc01cac01d0e2d55b8c18@18.196.238.210:26656,bdd98ec74fe56146f08e886239e52373f6821ce3@51.15.113.208:26656,e30d9bb713d17d1e4380b2e2a6df4b5c76c73eb1@34.212.106.82:26656"/g' ~/.desmosd/config/config.toml

echo "===> Completed Desmos setup"
echo ""

####################################
## Setup the service
####################################
echo "===> Setting up Desmos service"

FILE=/etc/systemd/system/desmosd.service
sudo tee $FILE > /dev/null <<EOF
[Unit]
Description=Desmos full node watched by Cosmovisor
After=network-online.target
[Service]
User=$USER
ExecStart=$GOBIN/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment="DAEMON_NAME=desmosd"
Environment="DAEMON_HOME=$HOME/.desmosd"
Environment="DAEMON_RESTART_AFTER_UPGRADE=on"
[Install]
WantedBy=multi-user.target
EOF

echo "====> Starting Desmos service"
sudo systemctl daemon-reload
sudo systemctl enable desmosd
sudo systemctl restart desmosd

tail -100f /var/log/syslog
