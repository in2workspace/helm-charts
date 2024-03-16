#!/bin/sh
# Start the Vault server in the background
vault server -config=/vault/config/config.json &

# Wait for the server to start up
sleep 5

# Set the Vault address environment variable
export VAULT_ADDR="http://0.0.0.0:8201"

# Check the status of Vault
STATUS=$(vault status 2>&1)
INITIALIZED=$(echo "$STATUS" | grep 'Initialized' | awk '{print $2}')
SEALED=$(echo "$STATUS" | grep 'Sealed' | awk '{print $2}')

# If Vault is not initialized and is sealed, initialize and unseal it
if [ "$INITIALIZED" = "false" ] && [ "$SEALED" = "true" ]; then
    echo "Initializing and Unsealing Vault..."
    vault operator init > /vault/generated_keys.txt

    # Extract the unseal keys
    keyArray=$(grep "Unseal Key " /vault/generated_keys.txt | cut -c15-)
    set -- $keyArray
    # Unseal the Vault
    vault operator unseal $1
    vault operator unseal $2
    vault operator unseal $3

    # Retrieve the root token
    rootToken=$(grep "Initial Root Token: " /vault/generated_keys.txt | cut -c21-)
    echo $rootToken > /vault/root_token.txt
    export VAULT_TOKEN=$rootToken

    # Enable key-value (KV) storage
    vault secrets enable -version=1 kv

# If Vault is initialized but is sealed, only unseal it
elif [ "$INITIALIZED" = "true" ] && [ "$SEALED" = "true" ]; then
    echo "Unsealing Vault..."
    # Unseal Vault using the stored keys
    # Extract the unseal keys
    keyArray=$(grep "Unseal Key " /vault/generated_keys.txt | cut -c15-)
    set -- $keyArray
    vault operator unseal $1
    vault operator unseal $2
    vault operator unseal $3
fi

# Wait for the Vault server to stop before exiting the script
wait $(pgrep vault)
