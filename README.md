<p align="center">
  <img height="100" height="auto" src="https://user-images.githubusercontent.com/50621007/177979901-4ac785e2-08c3-4d61-83df-b451a2ed9e68.png">
</p>

# Aura Mainnet — xstaxy-1

Official documentation:
>- [Validator setup instructions](https://docs.aura.app/run-a-node)

Explorer:
>- [https://aurascan.io](https://aurascan.io)

### Minimum Hardware Requirements
 - 3x CPUs; the faster clock speed the better
 - 4GB RAM
 - 80GB Disk

### Recommended Hardware Requirements 
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 200GB of storage (SSD or NVME)

## Set up your aura fullnode
```
wget https://raw.githubusercontent.com/freshe4qa/aura/main/aura.sh && chmod +x aura.sh && ./aura.sh
```

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Synchronization status:
```
aurad status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
aurad keys add $WALLET
```

Recover your wallet using seed phrase
```
aurad keys add $WALLET --recover
```

To get current list of wallets
```
aurad keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu aurad -o cat
```

Start service
```
sudo systemctl start aurad
```

Stop service
```
sudo systemctl stop aurad
```

Restart service
```
sudo systemctl restart aurad
```

### Node info
Synchronization info
```
aurad status 2>&1 | jq .SyncInfo
```

Validator info
```
aurad status 2>&1 | jq .ValidatorInfo
```

Node info
```
aurad status 2>&1 | jq .NodeInfo
```

Show node id
```
aurad tendermint show-node-id
```

### Wallet operations
List of wallets
```
aurad keys list
```

Recover wallet
```
aurad keys add $WALLET --recover
```

Delete wallet
```
aurad keys delete $WALLET
```

Get wallet balance
```
aurad query bank balances $AURA_WALLET_ADDRESS
```

Transfer funds
```
aurad tx bank send $AURA_WALLET_ADDRESS <TO_AURA_WALLET_ADDRESS> 10000000uaura
```

### Voting
```
aurad tx gov vote 1 yes --from $WALLET --chain-id=$AURA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
aurad tx staking delegate $AURA_VALOPER_ADDRESS 10000000uaura --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
aurad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uaura --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
aurad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$AURA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
aurad tx distribution withdraw-rewards $AURA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$AURA_CHAIN_ID
```

Unjail validator
```
aurad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$AURA_CHAIN_ID \
  --gas=auto
```
