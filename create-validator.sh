desmoscli tx staking create-validator \
  --amount=1000000udaric \
  --pubkey=$(desmosd tendermint show-validator) \
  --moniker=$(cat /root/desmos/acc_name.txt) \
  --chain-id=morpheus-10000 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas="auto" \
  --gas-adjustment="1.2" \
  --gas-prices="0.025udaric" \
  --from=desmos