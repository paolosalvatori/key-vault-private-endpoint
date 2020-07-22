#!/bin/bash

# Variables
keyVaultServiceEndpoint=$1
blobServicePrimaryEndpoint=$2

# Parameter validation
if [[ -z $keyVaultServiceEndpoint ]]; then
    echo "keyVaultServiceEndpoint cannot be null or empty"
    exit 1
else
    echo "keyVaultServiceEndpoint: $keyVaultServiceEndpoint"
fi

if [[ -z $blobServicePrimaryEndpoint ]]; then
    echo "blobServicePrimaryEndpoint cannot be null or empty"
    exit 1
else
    echo "blobServicePrimaryEndpoint: $blobServicePrimaryEndpoint"
fi

# Extract the key vault name from the adls service primary endpoint
keyVaultName=$(echo "$keyVaultServiceEndpoint" | awk -F'.' '{print $1}')

if [[ -z $keyVaultName ]]; then
    echo "keyVaultName cannot be null or empty"
    exit 1
else
    echo "keyVaultName: $keyVaultName"
fi

# Eliminate debconf: warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Install curl and traceroute
sudo apt install -y curl traceroute

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Run nslookup to verify that the <storage-account>.dfs.core.windows.net public hostname of the storage account 
# is properly mapped to <storage-account>.privatelink.dfs.core.windows.net by the privatelink.dfs.core.windows.net 
# private DNS zone and the latter is resolved to the private address by the A record
nslookup $keyVaultServiceEndpoint

# Run nslookup to verify that the <storage-account>.blob.core.windows.net public hostname of the storage account 
# is properly mapped to <storage-account>.privatelink.blob.core.windows.net by the privatelink.blob.core.windows.net 
# private DNS zone and the latter is resolved to the private address by the A record
nslookup $blobServicePrimaryEndpoint

# Login using the virtual machine system-assigned managed identity
az login --identity --allow-no-subscriptions

# Retrieve the list of secrets
az keyvault secret list --vault-name $keyVaultName