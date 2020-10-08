#!/bin/bash

MONIKER=desmos
DESMOSCLI="/root/go/bin/desmoscli"

while true; 
do 
    OPERATOR=$($DESMOSCLI q staking delegations $($DESMOSCLI keys list | jq -r .[0].address) | jq -r .[].validator_address)
    STATUS=$($DESMOSCLI query staking validator $OPERATOR --trust-node -o json | jq -r .status)
    if [[ $STATUS != "2" ]]; then
        echo "UNJAIL"
        $DESMOSCLI tx slashing unjail --from $MONIKER --gas-adjustment="1.5" --gas="auto" --gas-prices="0.025udaric" --chain-id=morpheus-10000 -y
    fi
    sleep 300
done
