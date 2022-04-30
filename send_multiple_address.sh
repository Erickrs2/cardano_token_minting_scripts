#!/bin/bash
set -e

###############################################################################
###############################################################################
NAME="minter"
SENDER_ADDR=$(cat ${NAME}/${NAME}_base.addr)
RECEIVER_ADDR=$(cat receiver.addr)

R1=addr_test1qz0lx84r0tshly6hm68gw3kfrgpxskwqjhzg236gwaqt0v4artjpvu9uj06lgmdv6v43002sng8a0a63xe7dasahyw9qe7yxtm
R2=addr_test1qz9w8zcxz2u0jn5kjknn3p6kydmwnhpa4tc6vmthdf7sxh27zjt57qrt0r2y59x744ve5dkp4r4t6a2fqcgjg43ljs2q2859yj
R3=addr_test1qqu43zhvd436l9mle6g37an438l3ajjl4yndvhp9s45q66nrfxz2r8sphdr9x0vtsna6r6ld2a9vmhkuzsgq59gyklws0jj292
R4=addr_test1qqj8xfdzantk8tc6h452fna6ctajq8y64pfupwghw4k4k20l0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmqgje3ph
R5=addr_test1qzpz33wzgpe26ctc3rfhuwmusjlcdu54gggcwlen7dyd5ehl0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmq89vama
R6=addr_test1qpk4kywmqupfunswyuu707a45ame3qs7x437dmwylncnzw8l0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmq52adj6
R7=addr_test1qp6n0ankmmlxlmf9znr3lfxvv9u9zu8njw5yla56umpzrjhl0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmqdr9m70
R8=addr_test1qq2qr5z6sraw7qwnz6778xnhj5ec3wlksc25mdhlfwxcpn0l0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmqr95txm
R9=addr_test1qqf6yekh3jczkzvlnyhzldekw4tpe6x7nnsrtwze65k9h3hl0dw5r75vk42mv3ykq8vyjeaanvpytg79xqzymqy5acmqmhqm0m
R10=addr_test1qrnq5qwntxnfyyu3atmak7z2t2jn432q5t86axtt6zln9ts8m6vrrd3cml8um378k67awg0xnss8fvhxtpy5qjcm7ujseydv0j
R11=addr_test1qztxvgp3aht22atmnrsznkwyaszdhkyx6tlzr9krkx80gu7p7h0j6ypatzcy7s8g7ulzg7zuh7zewgcayshsg29k0mmqgqcnkf
R12=addr_test1qzrwwh76rny3x4stq2cx0j2d2n28xwyhpup8zlzne75jzlngrnkw3ewxurn9kuwfuq7gexjulr0s9wthlxa37z2ezwcqellatg
R13=addr_test1qq999p8ywkkp6ew5z57glc43wyrmnywthvegf48x08yu2fwzpeepd6klddx68pcd9ssp29wkqevanp6u3l44qdd0jxtqcj0a70

A1=10000000
A2=10000000
A3=10000000
A4=5000000
A5=5000000
A6=5000000
A7=5000000
A8=5000000
A9=4000000
A10=3000000
A11=3000000
A12=1000000
A13=1000000

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

# Passive relay or Daedalus is required.
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


echo "Building Draft Transaction"
cardano-cli transaction build-raw \
--fee 0 \
--tx-in $HEXTXIN \
--tx-out ${R1}+${A1} \
--tx-out ${R2}+${A2} \
--tx-out ${R3}+${A3} \
--tx-out ${R4}+${A4} \
--tx-out ${R5}+${A5} \
--tx-out ${R6}+${A6} \
--tx-out ${R7}+${A7} \
--tx-out ${R8}+${A8} \
--tx-out ${R9}+${A9} \
--tx-out ${R10}+${A10} \
--tx-out ${R11}+${A11} \
--tx-out ${R12}+${A12} \
--tx-out ${R13}+${A13} \
--tx-out ${RECEIVER_ADDR}+${ADA_BALANCE} \
--invalid-hereafter $FINALTIP \
--out-file tx.draft

echo "Calculating Transaction Fee"
FEE=$(cardano-cli transaction calculate-min-fee \
--tx-body-file tx.draft \
--tx-in-count ${TXNS} \
--tx-out-count 14 \
--witness-count 1 \
--testnet-magic 1097911063 \
--protocol-params-file protocol.json \
| tr -dc '0-9')

echo $SENDER "has" $BALANCE "ADA"
echo "The fee is" ${FEE} "to move" ${ADA_BALANCE} "Lovelace"
CHANGE=$((${ADA_BALANCE} - ${FEE} - ${A1} - ${A2} - ${A3} - ${A4} - ${A5} - ${A6} - ${A7} - ${A8} - ${A9} - ${A10} - ${A11} - ${A12} - ${A13}))
echo "The change is" ${CHANGE}


echo "Building Raw Transaction"
cardano-cli transaction build-raw \
--fee $FEE \
--tx-in $HEXTXIN \
--tx-out ${R1}+${A1} \
--tx-out ${R2}+${A2} \
--tx-out ${R3}+${A3} \
--tx-out ${R4}+${A4} \
--tx-out ${R5}+${A5} \
--tx-out ${R6}+${A6} \
--tx-out ${R7}+${A7} \
--tx-out ${R8}+${A8} \
--tx-out ${R9}+${A9} \
--tx-out ${R10}+${A10} \
--tx-out ${R11}+${A11} \
--tx-out ${R12}+${A12} \
--tx-out ${R13}+${A13} \
--tx-out ${RECEIVER_ADDR}+${CHANGE} \
--invalid-hereafter $FINALTIP \
--out-file tx.raw

echo "Signing Transaction"
cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file "../minter/minter_payment.skey" \
--testnet-magic 1097911063 \
--out-file tx.signed

# ###### THIS MAKES IT LIVE #####################################################
# cardano-cli transaction submit \
# --tx-file tx.signed \
# --testnet-magic 1097911063
# ##############################################################################