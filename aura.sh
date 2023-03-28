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
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export AURA_CHAIN_ID=xstaxy-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
fi

# download binary
cd $HOME && rm -rf aura
git clone https://github.com/aura-nw/aura.git
cd aura
git checkout aura_v0.4.4
make build

# config
aurad config chain-id $AURA_CHAIN_ID
aurad config keyring-backend file

# init
aurad init $NODENAME --chain-id $AURA_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/aura-nw/mainnet-artifacts/main/xstaxy-1/genesis.json > $HOME/.aura/config/genesis.json
curl -s https://snapshots1.nodejumper.io/aura/addrbook.json > $HOME/.aura/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0001uaura\"|" $HOME/.aura/config/app.toml

# set peers and seeds
SEEDS="22a0ca5f64187bb477be1d82166b1e9e184afe50@18.143.52.13:26656,0b8bd8c1b956b441f036e71df3a4d96e85f843b8@13.250.159.219:26656"
PEERS="5ce29d0d9ef1230eab07444dd73745d68a832d6f@aura.nodejumper.io:40656,f0c43af5395c36e41fcf7526c05d3c44e97b9499@185.165.241.20:26666,19acd62323adff35539c6c3643e1a5e097caece4@5.9.61.78:26656,3e7ef25f1c9829351936884618659167400eb0f1@142.132.149.171:26656,fc3357ab9ebd2e9530177848187e870b7404ed8e@185.246.84.196:21656,7885a9e940b45b9a2183488ca3a901b043b6ed67@144.76.40.53:21756,eec4c706ee03921d103018647a4695706bc91b21@13.212.73.184:26656,8c7b98babcf101a591533bfa0fbd5c1ac103dbce@51.222.254.27:26656,fa474fe8f7159c9699fb39acb2925702f0474502@141.95.157.139:10156,a1f949c765bfc493ddd2e0e8477170bcc3b86a57@194.163.179.176:16656,07317346ab58eb4de14fe8c7705863002186d340@142.132.201.53:36656,2a6c9c568980bbaff753ed362f48272c203cc77e@116.98.182.254:26656,c0c33d6f9e4868f5a40f3ccb9f638fbd215d8874@188.165.200.129:17656,d2ea7c421c8bb552b84eba4c7924f9e78d3a79ae@176.9.158.219:41256,c2215f1673d21a7462f38bf7fbd16f8567393f7c@13.251.159.166:26656,e46238ddcf2113b70f59b417994c375e2d67e265@71.236.119.108:40656,5816c78cdedd57cd8c647595903504f3779d5017@45.141.122.178:32656,10b4cb9cbd7d3dae1aacc97355c1269ce5e36c57@93.190.141.68:21056,65bf908c6c41cacfce9652ed69a17337b023d0d0@57.128.85.172:26656,8d861db065439e8cff79d0d128ce0a141025be46@65.109.69.154:40656,aec1624fad0adf47f9b4f7300dcb8bd4d63567f1@57.128.20.163:26656,a58b4dec687b60ba05cf9a3e4cd1181b09c0661f@65.109.93.152:34656,ed15ae05f17dd4e672eec0a96c38364d063b68dc@65.108.6.45:60756,22a0ca5f64187bb477be1d82166b1e9e184afe50@18.143.52.13:26656,b91ee5c72905bc49beed2720bb882c923c68fbc9@80.92.206.66:26656,0599779759ed60e12ed39a94cd02d303ba10d591@95.214.52.174:36656,f43c7c9a194ee5a97665a9aad8f887fdbb75e4ca@65.109.225.86:46656,0179528068da0dfaf61005cf5aa28793ca42b129@85.25.74.163:26656,b6a0d0d030f35ffffcfe92e72ea13933c1adbe62@116.202.174.253:21656,0b8bd8c1b956b441f036e71df3a4d96e85f843b8@13.250.159.219:26656,a19b89ebbf7331f435b8ef100ce501d2377922ea@209.126.116.182:26656,a859027129ee2524b57c43b9ecbe3bcc4d120efb@195.3.222.183:26656,ebc272824924ea1a27ea3183dd0b9ba713494f83@95.214.52.139:26966,f67f9a6f5121b6388c84812a812d5d6eca0b39e8@148.251.66.248:26656,3e05f2b0fdd750511dbff9d3f6a47d3bc3d4b1f0@141.95.204.81:61456,1f536bba1e1922d8920ab742afd8c78b447c68b2@194.163.178.191:26676,71bb73be4f030e47b813350ee32076ee43c67c27@134.209.111.108:26656,edbd221ceecf4e0234fb60d617a025c6b0e56bf0@178.250.154.15:36656,dc9c2ab4055a2ef8ddca435e9d8c120969562f98@194.247.13.139:26656,fdd10b168d1217d5a0557d2e31ed27c914c97674@135.181.215.62:7530,ddad7ae9754de0a474a7bb14f063a17d0fbcf510@107.155.65.7:26656,bbba624f6abc7b730a8e3f1cc0619883843abd31@104.37.187.214:36656,d9bfa29e0cf9c4ce0cc9c26d98e5d97228f93b0b@65.109.88.38:17656,5e87d03a29ceca5e376e55588d9b099bb5d9524f@144.202.72.17:25656,1584b3aa3969def4a9f70555b3b442d334053e94@148.113.159.22:10156,a60a9f3400cb978b313ad5a47d59f6c518ef2a04@3.135.201.61:26656,690e0fca18e89118f096b48a4d615a4cc56cdddd@194.126.172.246:12243,2b837edb779038f29785b347fb78397ab7dec3bf@148.251.88.145:10456,ca92abdc4599dd91dd63e689c64c468df5425f2c@95.216.100.99:17656,63a90346040657406ddc48a2679e3bfbe17f717a@65.108.195.29:51656,57406c041d38af3bac9acdcb2b4bdc90dc7a8852@88.99.164.158:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.aura/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.aura/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.aura/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.aura/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.aura/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.aura/config/config.toml

# create service
sudo tee /etc/systemd/system/aurad.service > /dev/null << EOF
[Unit]
Description=Aura Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which aurad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

# reset
aurad tendermint unsafe-reset-all --home $HOME/.aura --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots1.nodejumper.io/aura/info.json | jq -r .fileName)
curl "https://snapshots1.nodejumper.io/aura/${SNAP_NAME}" | lz4 -dc - | tar -xf - -C "$HOME/.aura"

# start service
sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid

break
;;

"Create Wallet")
aurad keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
AURA_WALLET_ADDRESS=$(aurad keys show $WALLET -a)
AURA_VALOPER_ADDRESS=$(aurad keys show $WALLET --bech val -a)
echo 'export AURA_WALLET_ADDRESS='${AURA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export AURA_VALOPER_ADDRESS='${AURA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
aurad tx staking create-validator \
--amount 1000000uaura \
--pubkey $(aurad tendermint show-validator) \
--moniker $NODENAME \
--chain-id xstaxy-1 \
--commission-rate 0.05 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from wallet \
--gas-adjustment 1.4 \
--gas auto \
--gas-prices 0.001uaura \
-y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
