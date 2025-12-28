#!/usr/bin/env bash
set -Eeuo pipefail

# Install jq for JSON parsing
tdnf install -y jq

# Obtain AAD access token from the managed identity
aad_access_token=$(curl -H Metadata:true 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://containerregistry.azure.net/' | jq -r '.access_token')

# Exchange AAD access token for ACR refresh token and login
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=access_token&service=$Registry&tenant=$Tenant&access_token=$aad_access_token" https://$Registry/oauth2/exchange \
 | jq -r '.refresh_token' \
 | acr login $Registry -u 00000000-0000-0000-0000-000000000000 --password-stdin

acr "$@"