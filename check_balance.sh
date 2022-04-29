#!/bin/bash
set -e

###############################################################################
###############################################################################
NAME="minter"
SENDER_ADDR=$(cat ${NAME}/${NAME}_base.addr)
###############################################################################
###############################################################################

# Passive relay or Daedalus is required.
#
# Must have a live Network.Socket.connect

# get utxo
echo "Getting UTxO"
cardano-cli query utxo \
--cardano-mode \
--testnet-magic 1097911063 \
--address ${SENDER_ADDR}