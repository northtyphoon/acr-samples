# Running ACR Purge in ACI with a User Assigned Managed Identity

```sh
# Prerequisite
# 1) Install azure-cli

acr_name="the-name-of-the-acr"
aci_name="the-name-of-the-aci"
resource_group="the-name-of-the-resource-group-containing-aci"
subnet_id="the-resource-id-of-the-subnet-for-aci" # e.g. /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}
user_assigned_identity_id="the-resource-id-of-the-user-assigned-identity" # e.g. /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}

location=$(az network vnet show --ids $subnet_id --query location -o tsv)
registry=$(az acr show --name $acr_name --query loginServer -o tsv)
tenant_id=$(az identity show --ids $user_assigned_identity_id --query tenantId -o tsv)
principal_id=$(az identity show --ids $user_assigned_identity_id --query principalId -o tsv)
registry_resource_id=$(az acr show -n $registry_name --query "id" -o tsv)

# Assign AcrPush role to the User Assigned Managed Identity
# az role assignment create \
#   --role AcrPush \
#   --assignee-object-id $principal_id \
#   --assignee-principal-type ServicePrincipal \
#   --scope $registry_resource_id

# Assign AcrPush role to the User Assigned Managed Identity
# az network vnet subnet update \
#   --ids $subnet_id \
#   --delegations Microsoft.ContainerInstance/containerGroups

az container create \
  --resource-group $resource_group \
  --name $aci_name \
  --location $location \
  --subnet $subnet_id \
  --os-type Linux \
  --cpu 1 \
  --memory 1 \
  --image mcr.microsoft.com/acr/acr-cli:0.17 \
  --assign-identity $user_assigned_identity_id \
  --restart-policy Never \
  --gitrepo-url https://github.com/northtyphoon/acr-samples \
  --gitrepo-mount-path /mnt/gitrepo \
  --command-line "/mnt/gitrepo/acr-purge-in-aci/run-acr-with-mi.sh purge --registry $registry --filter 'hello-world:.*' --ago 7d --untagged --dry-run" \
  --environment-variables Registry=$registry Tenant=$tenant_id
  ```
