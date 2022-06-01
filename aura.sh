#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"


# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=halo-testnet-001" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y
sudo ufw allow 26656
sudo ufw allow 1317
sudo ufw allow 26657

# install go
source $HOME/.bash_profile
    if go version > /dev/null 2>&1
    then
        echo -e '\n\e[40m\e[92mSkipped Go installation\e[0m'
    else
        echo -e '\n\e[40m\e[92mStarting Go installation...\e[0m'
        cd $HOME && ver="1.17.2"
        wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
        sudo rm "go$ver.linux-amd64.tar.gz"
        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profilesource
        source $HOME/.bash_profile
        go version
    fi
    
#gcc
sudo apt update
sudo apt install build-essential -y
sudo apt-get install manpages-dev
gcc --version

#setup a full-node
wget https://github.com/aura-nw/aura/archive/refs/tags/halo_6ca81d8.tar.gz
tar -xzvf halo_6ca81d8.tar.gz
cd aura-halo_6ca81d8
make
aurad init $NODENAME
wget https://raw.githubusercontent.com/aura-nw/testnets/main/halo-testnet-001/genesis.json
mv genesis.json ~/.aura/config/genesis.json
cd

# config
aurad config chain-id halo-testnet-001
aurad config keyring-backend file

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uaura\"/" $HOME/.aura/config/app.toml

# set peers and seeds
SEEDS="10b5458c22c7dc6862ba9c2f4928a60af214c16c@3.210.178.93:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.aura/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.aura/config/config.toml

# reset
aurad unsafe-reset-all

# create service
tee $HOME/aurad.service > /dev/null <<EOF
[Unit]
Description=aurad
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which aurad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/aurad.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable aurad
sudo systemctl restart aurad

break
;;

"Create Wallet")
aurad keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
WALLET_ADDRESS=$(aurad keys show $WALLET -a)
VALOPER_ADDRESS=$(aurad keys show $WALLET --bech val -a)
echo 'export WALLET_ADDRESS='${WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export VALOPER_ADDRESS='${VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;


"Create Validator") 
aurad tx staking create-validator \
  --amount=1000000uaura \
  --pubkey=$(aurad tendermint show-validator) \
  --moniker $NODENAME  \
  --chain-id $CHAIN_ID \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --gas="auto" \
  --gas-prices=500uaura \
  --from $WALLET
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
