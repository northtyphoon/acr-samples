#!/usr/bin/env bash
set -Eeuo pipefail

tdnf install -y jq

aad_access_token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://containerregistry.azure.net/' -H Metadata:true | jq -r '.access_token')
acr_refresh_token=$(curl -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=access_token&service=$Registry&tenant=$Tenant&access_token=$aad_access_token" https://$Registry/oauth2/exchange)
$acr_refresh_token | acr login $Registry -u 00000000-0000-0000-0000-000000000000 --password-stdin

acr "$@"