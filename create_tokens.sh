#!/bin/bash
set -e


###############################################################################
###############################################################################
NAME="minter"
SENDER_ADDR=$(cat ${NAME}/${NAME}_base.addr)
# Policy and Assetname for NFT Here
POLICY_ID=$(cat policy/policy.id)
# Change this to your asset name
ASSET_NAME=$(echo -n "INTITECH" | xxd -ps | tr -d '\n')
# Create the minting string
# FT
MINT="10000 ${POLICY_ID}.${ASSET_NAME}"
# NFT
# MINT=""
# for i in $(seq -f "%05g" 1 10)
# do
#     MINT+="1 ${POLICY_ID}.${ASSET_NAME}${i} + "
# done
# MINT=${MINT::-3}
echo $MINT
###############################################################################
###############################################################################

# Check if a directory does not exist
if [ -d transaction ] 
then
  echo "Folder Exists."
else
  mkdir -p transaction
fi
cd transaction

# Passive relay or Daedalus is required.
#
# Must have a live Network.Socket.connect

# protocol
echo "Getting protocol parameters"
cardano-cli query protocol-parameters \
--testnet-magic 1097911063 \
--out-file protocol.json

# get utxo
echo "Getting the wallet's utxo"
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
BALANCE=$(jq .[].value.lovelace utxo.json | awk '{sum=sum+$0} END{print sum}' )
echo $BALANCE
echo $HEXTXIN

# Next tip before no transaction
echo "Getting chain tip"
cardano-cli query tip --testnet-magic 1097911063 --out-file tip.json
TIP=$(jq .slot tip.json)
echo $TIP
DELTA=200000
FINALTIP=$(( ${DELTA} + ${TIP} ))

echo "Building Draft Transaction"
cardano-cli transaction build-raw \
--fee 0 \
--tx-in $HEXTXIN \
--tx-out ${SENDER_ADDR}+${BALANCE}+"${MINT}" \
--mint "${MINT}" \
--metadata-json-file "../metadata/metadata.json" \
--invalid-hereafter $FINALTIP \
--minting-script-file "../policy/policy.script" \
--out-file tx.draft

echo "Calculating Transaction Fee"
FEE=$(cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count ${TXNS} \
--tx-out-count 1 \
--witness-count 3 \
--testnet-magic 1097911063 \
--protocol-params-file protocol.json \
| tr -dc '0-9')

echo $SENDER "has" $BALANCE "ADA"
echo "The fee is" ${FEE} "to move" ${BALANCE} "Lovelace"
CHANGE=$(( ${BALANCE} - ${FEE} ))
echo "The change is" ${CHANGE}

echo "Building Raw Transaction"
cardano-cli transaction build-raw \
--fee $FEE \
--tx-in $HEXTXIN \
--tx-out ${SENDER_ADDR}+${CHANGE}+"${MINT}" \
--mint "${MINT}" \
--metadata-json-file "../metadata/metadata.json" \
--invalid-hereafter $FINALTIP \
--minting-script-file "../policy/policy.script" \
--out-file tx.raw

echo "Signing Transaction"
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file "../minter/minter_payment.skey" \
--signing-key-file "../policy/policy.skey" \
--testnet-magic 1097911063 \
--out-file tx.signed

# ###### THIS MAKES IT LIVE #####################################################
# echo "Submitting transaction"
# cardano-cli transaction submit \
# --tx-file tx.signed \
# --testnet-magic 1097911063
# ###############################################################################