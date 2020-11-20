#!/bin/bash

BIN_FILE="/root/go/bin/desmoscli"
RPC_PORT="26657"
WALLET_NAME="desmos"
CHAIN_ID="morpheus-10000"
SELF_ADDR=$($BIN_FILE keys list -o json | jq -r '.[] | select(.name=="desmos") | .address')
DENOM="udaric"
OPERATOR=$($BIN_FILE q staking delegations -o json --chain-id $CHAIN_ID $SELF_ADDR | jq -r .[].validator_address)

echo -e "Current address: $SELF_ADDR\nCurrent operator address: $OPERATOR"

while true;
do
    BALANCE=$($BIN_FILE query account $SELF_ADDR -o json | jq -r .value.coins[0].amount)
    echo CURRENT BALANCE IS: $BALANCE
    REWARD=$(( $BALANCE - 333333 ))

    if (( $BALANCE >  899999 )); then
        echo "Let's delegate $REWARD of REWARD tokens to $SELF_ADDR"
        # delegate balance
        $BIN_FILE tx staking delegate $OPERATOR "$REWARD"$DENOM --chain-id $CHAIN_ID --node http://localhost:$RPC_PORT --gas-adjustment 1.5 --gas="200000" --fees 333333$DENOM --from $SELF_ADDR -y

    else
        echo "Reward is $REWARD"
    fi
    sleep 500
done
echo "DONE"
