#!/bin/bash
set -e

###############################################################################
###############################################################################
NAME="minter"
SENDER_ADDR=$(cat ${NAME}/${NAME}_base.addr)
RECEIVER_ADDR=$(cat receiver.addr)
POLICY_ID=$(cat policy/policy.id)
ASSET_NAME=$(echo -n "IntiTech" | xxd -ps | tr -d '\n')
# # FT minting string
MINT="2021 ${POLICY_ID}.${ASSET_NAME}"
# # NFT minting string
# MINT=""
# for i in $(seq -f "%05g" 1 10)
# do
#     MINT+="1 ${POLICY_ID}.${ASSET_NAME}${i} + "
# done
# MINT=${MINT::-3}
echo $MINT
###############################################################################
###############################################################################

### Check if a directory does not exist ###
if [ -d transaction ] 
then
  echo "Folder Exists."
else
  mkdir -p transaction
fi
cd transaction

# Passive relay or Daedalus required is required.
#
# Must have a live Network.Socket.connect

# protocol
echo "Getting protocol parameters"
cardano-cli query protocol-parameters \
--testnet-magic 1097911063 \
--out-file protocol.json

# get utxo
echo "Getting utxo"
cardano-cli query utxo \
--cardano-mode \
--testnet-magic 1097911063 \
--address ${SENDER_ADDR} \
--out-file utxo.json

# transaction variables
TXNS=$(jq length utxo.json)
alltxin=""
TXIN=$(jq -r --arg alltxin "" 'keys[] | . + $alltxin + " --tx-in"' utxo.json)
HEXTXIN=${TXIN::-8}
ADA_BALANCE=$(jq .[].value.lovelace utxo.json | awk '{sum=sum+$0} END{print sum}' )
echo "ADA" ${ADA_BALANCE}

# Next tip before no transaction
echo "Getting chain tip"
cardano-cli query tip --testnet-magic 1097911063 --out-file tip.json
TIP=$(jq .slot tip.json)
DELTA=200000
FINALTIP=$(( ${DELTA} + ${TIP} ))
echo $FINALTIP

echo "Building Draft Transaction"
cardano-cli transaction build-raw \
--fee 0 \
--tx-in $HEXTXIN \
--tx-out ${RECEIVER_ADDR}+${ADA_BALANCE}+"${MINT}" \
--invalid-hereafter $FINALTIP \
--out-file tx.draft

echo "Calculating Transaction Fee"
FEE=$(cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count ${TXNS} \
--tx-out-count 2 \
--witness-count 3 \
--testnet-magic 1097911063 \
--protocol-params-file protocol.json \
| tr -dc '0-9')

echo $SENDER "has" $BALANCE "ADA"
echo "The fee is" ${FEE} "to move" ${ADA_BALANCE} "Lovelace"
CHANGE=$(( ${ADA_BALANCE} - ${FEE} ))
echo "The change is" ${CHANGE}


echo "Building Raw Transaction"
cardano-cli transaction build-raw \
--fee $FEE \
--tx-in $HEXTXIN \
--tx-out ${RECEIVER_ADDR}+${CHANGE}+"${MINT}" \
--invalid-hereafter $FINALTIP \
--out-file tx.raw

echo "Signing Transaction"
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file "../minter/minter_payment.skey" \
--testnet-magic 1097911063 \
--out-file tx.signed

# ###### THIS MAKES IT LIVE #####################################################
# echo "submitting transaction"
# cardano-cli transaction submit \
# --tx-file tx.signed \
# --testnet-magic 1097911063
# ##############################################################################