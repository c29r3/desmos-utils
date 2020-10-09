#!/bin/bash

BIN_FILE="/root/go/bin/desmoscli"
WALLET_NAME="desmos"
CHAIN_ID="morpheus-10000"
SELF_ADDR=$($BIN_FILE keys list | jq -r .[0].address)
DENOM="udaric"
OPERATOR=$($BIN_FILE q staking delegations --chain-id $CHAIN_ID $SELF_ADDR | jq -r .[].validator_address)

echo -e "Current address: $SELF_ADDR\nCurrent operator address: $OPERATOR"

while true;
do
    BALANCE=$($BIN_FILE query account $SELF_ADDR -o json | jq -r .value.coins[0].amount)
    echo CURRENT BALANCE IS: $BALANCE
    REWARD=$(( $BALANCE - 2000000 ))

    if (( $BALANCE >  8999999 )); then
        echo "Let's delegate $REWARD of REWARD tokens to $SELF_ADDR"
        # delegate balance
        $BIN_FILE tx staking delegate $OPERATOR "$REWARD"$DENOM --chain-id $CHAIN_ID --gas-adjustment 1.5 --gas="200000" --gas-prices "0.01"$DENOM --from $WALLET_NAME -y

    else
        echo "Reward is $REWARD"
    fi
    sleep 500
done
echo "DONE"
