# cardano_minting_scripts1

An image can be added to the ipfs using blockfrost.

```bash
curl "https://ipfs.blockfrost.io/api/v0/ipfs/add" \
    -X POST \
    -H "project_id: BLOCKFROST_API_KEY_HERE" \
    -F "file=@./filepath"
```

If a minter wallet does not exist then run the create_wallet.sh script. This will create the wallet folder, payment keys, address, and qr code image.

```bash
# Requires qr to be on path
bash create_wallet.sh
```

Create a general policy script that allows for minting and burning at anytime. This file can be updated to the use case. Be sure to update the policy id after modifying the contents of the policy script.

```bash
# Requires jq to be on path
bash create_policy.sh
# Edit policy.script then update the policy.id file.
cardano-cli transaction policyid --script-file policy.script
```


The minting flow

```bash
# Create the custom metadata to your needs.
# Adjust the create token parameters for your needs.
# Make adjustments before running the create token script.
bash create_tokens.sh
```

Be sure to put the receiving address into the receiver.addr file.

```bash
# Adjust the create token parameters for your needs.
# Make adjustments before running the send token script.
bash send_tokens.sh
```

You can check the wallet balance with

```bash
bash check_balance.sh
```

After sending tokens if there is leftover ADA in the wallet you can use the send_ada.sh script to remove any leftover into the receiving wallet.