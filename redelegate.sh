#!/bin/bash

SELF_ADDR="ADDR"
OPERATOR="desmosvaloper...."
WALLET_NAME="wallet_name"
CHAIN_ID="desmos-mainnet"
WALLET_PWD=""
BIN_FILE="$HOME/go/bin/desmos"
TOKEN="udsm"
RPC="http://135.181.60.250:26557"


while true; do
    # withdraw reward
    echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx distribution withdraw-rewards $OPERATOR --commission --fees 5000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME --node ${RPC} -y

    sleep 10

    # check current balance
    BALANCE=$($BIN_FILE q bank balances $SELF_ADDR -o json --node ${RPC} | jq -r .balances[0].amount)
    echo CURRENT BALANCE IS: $BALANCE

    RESTAKE_AMOUNT=$(( $BALANCE - 5000000 ))

    if (( $RESTAKE_AMOUNT >=  25000000 ));then
        echo "Let's delegate $RESTAKE_AMOUNT of REWARD tokens to $SELF_ADDR"
        # delegate balance
        echo -e "$WALLET_PWD\n$WALLET_PWD\n" | $BIN_FILE tx staking delegate $OPERATOR "$RESTAKE_AMOUNT"$TOKEN --fees 5000$TOKEN --chain-id $CHAIN_ID --from $WALLET_NAME --node ${RPC} -y

    else
        echo "Reward is $RESTAKE_AMOUNT"
    fi
    echo "DONE"
    sleep 10800
done
