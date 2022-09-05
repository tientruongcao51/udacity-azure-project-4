#!/bin/bash

# Variables
resourceGroup="cloud-demo"
location="southcentralus"
osType="UbuntuLTS"
vmssName="udacity-vmss"
adminName="udacityadmin"
storageAccount="truongcao$RANDOM"
bePoolName="$vmssName-bepool"
lbName="$vmssName-lb"
lbRule="$lbName-network-rule"
nsgName="$vmssName-nsg"
vnetName="$vmssName-vnet"
subnetName="$vnetName-subnet"
probeName="tcpProbe"
vmSize="Standard_D2s_v3"
storageType="Standard_LRS"

# Create resource group.
# This command will not work for the Cloud Lab users.
# Cloud Lab users can comment this command and
# use the existing Resource group name, such as, resourceGroup="cloud-demo-153430"
echo "STEP 0 - Creating resource group $resourceGroup..."
echo "Skipped because I am using the Lab enviroment"
# az group create \
# --name $resourceGroup \
# --location $location \
# --verbose

echo "Resource group created: $resourceGroup"

# Create Storage account
echo "STEP 1 - Creating storage account $storageAccount"

az storage account create \
--name $storageAccount \
--resource-group $resourceGroup \
--location $location \
--sku Standard_LRS

echo "Storage account created: $storageAccount"

# Create Network Security Group
echo "STEP 2 - Creating network security group $nsgName"

az network nsg create \
--resource-group $resourceGroup \
--name $nsgName \
--verbose

echo "Network security group created: $nsgName"

# Create VM Scale Set
echo "STEP 3 - Creating VM scale set $vmssName"

az vmss create \
  --resource-group $resourceGroup \
  --name $vmssName \
  --image $osType \
  --vm-sku $vmSize \
  --nsg $nsgName \
  --subnet $subnetName \
  --vnet-name $vnetName \
  --backend-pool-name $bePoolName \
  --storage-sku $storageType \
  --load-balancer $lbName \
  --custom-data cloud-init.txt \
  --upgrade-policy-mode automatic \
  --admin-username $adminName \
  --generate-ssh-keys \
  --verbose

echo "VM scale set created: $vmssName"

# Associate NSG with VMSS subnet
echo "STEP 4 - Associating NSG: $nsgName with subnet: $subnetName"

az network vnet subnet update \
--resource-group $resourceGroup \
--name $subnetName \
--vnet-name $vnetName \
--network-security-group $nsgName \
--verbose

echo "NSG: $nsgName associated with subnet: $subnetName"

# Create Health Probe
echo "STEP 5 - Creating health probe $probeName"

az network lb probe create \
  --resource-group $resourceGroup \
  --lb-name $lbName \
  --name $probeName \
  --protocol tcp \
  --port 80 \
  --interval 5 \
  --threshold 2 \
  --verbose

echo "Health probe created: $probeName"

# Create Network Load Balancer Rule
echo "STEP 6 - Creating network load balancer rule $lbRule"

az network lb rule create \
  --resource-group $resourceGroup \
  --name $lbRule \
  --lb-name $lbName \
  --probe-name $probeName \
  --backend-pool-name $bePoolName \
  --backend-port 80 \
  --frontend-ip-name loadBalancerFrontEnd \
  --frontend-port 80 \
  --protocol tcp \
  --verbose

echo "Network load balancer rule created: $lbRule"

# Add port 80 to inbound rule NSG
echo "STEP 7 - Adding port 80 to NSG $nsgName"

az network nsg rule create \
--resource-group $resourceGroup \
--nsg-name $nsgName \
--name Port_80 \
--destination-port-ranges 80 \
--direction Inbound \
--priority 100 \
--verbose

echo "Port 80 added to NSG: $nsgName"

# Add port 22 to inbound rule NSG
echo "STEP 8 - Adding port 22 to NSG $nsgName"

az network nsg rule create \
--resource-group $resourceGroup \
--nsg-name $nsgName \
--name Port_22 \
--destination-port-ranges 22 \
--direction Inbound \
--priority 110 \
--verbose

echo "Port 22 added to NSG: $nsgName"

echo "VMSS script completed!"

#
#}
#Network security group created: udacity-vmss-nsg
#STEP 3 - Creating VM scale set udacity-vmss
#INFO: Use existing SSH public key file: C:\Users\tient\.ssh\id_rsa.pub
#WARNING: It is recommended to use parameter "--lb-sku Standard" to create new VMSS with Standard load balancer. Please note that the default load balancer used for VMSS creation will be changed from Basic to Standard in the future.
#ERROR: {"error":{"code":"InvalidTemplateDeployment","message":"The template deployment failed because of policy violation. Please see details for more information.","details":[{"code":"RequestDisallowedByPolicy","target":"udacity-vmss","message":"Resource 'udacity-vmss' was disallowed by policy. Policy identifiers: '[{\"policyAssignment\":{\"name\":\"cloud-demo513-PolicyDefinition\",\"id\":\"/subscriptions/17fc1a23-7619-4af8-9180-e8388fc413a3/providers/Microsoft.Authorization/policyAssignments/cloud-demo513-PolicyDefinition\"},\"policyDefinition\":{\"name\":\"cloud-demo513-PolicyDefinition\",\"id\":\"/subscriptions/17fc1a23-7619-4af8-9180-e8388fc413a3/providers/Microsoft.Authorization/policyDefinitions/cloud-demo513-PolicyDefinition\"}},{\"policyAssignment\":{\"name\":\"UdacityCommon policy definition\",\"id\":\"/providers/Microsoft.Management/managementGroups/udacitydedicatedsubscriptionGroup1/providers/Microsoft.Authorization/policyAssignments/891f056473974f7289c7b312\"},\"policyDefinition\":{\"name\":\"UdacityCommon policy definition\",\"id\":\"/providers/Microsoft.Management/managementGroups/udacitydedicatedsubscriptionGroup1/providers/Microsoft.Authorization/policyDefinitions/UdacityCommonPolicyDefinition\"}}]'.","additionalInfo":[{"type":"PolicyViolation","info":{"evaluationDetails":{"evaluatedExpressions":[{"result":"True","expressionKind":"Field","expression":"type","path":"type","expressionValue":"Microsoft.Compute/virtualMachineScaleSets","targetValue":"Microsoft.Compute/virtualMachineScaleSets","operator":"Equals"},{"result":"False","expressionKind":"Field","expression":"Microsoft.Compute/virtualMachineScaleSets/sku.name","path":"sku.name","expressionValue":"Standard_D2as_v4","targetValue":["Standard_D1_v2","Standard_D2_v2","Standard_D3_v2","Standard_D2s_v3","Standard_D4s_v3","Standard_B1s","Standard_B2s","Standard_B1ms","Standard_B2ms","Standard_B4ms","Standard_D2s_v2","Standard_DS1_v2","Standard_DS2_v2","Standard_DS3_v2","Standard_DS1","Standard_DS2","Standard_DS3"],"operator":"In"}]},"policyDefinitionId":"/subscriptions/17fc1a23-7619-4af8-9180-e8388fc413a3/providers/Microsoft.Authorization/policyDefinitions/cloud-demo513-PolicyDefinition","policyDefinitionName":"cloud-demo513-PolicyDefinition","policyDefinitionDisplayName":"cloud-demo513-PolicyDefinition","policyDefinitionEffect":"deny","policyAssignmentId":"/subscriptions/17fc1a23-7619-4af8-9180-e8388fc413a3/providers/Microsoft.Authorization/policyAssignments/cloud-demo513-PolicyDefinition","policyAssignmentName":"cloud-demo513-PolicyDefinition","policyAssignmentDisplayName":"cloud-demo513-PolicyDefinition","policyAssignmentScope":"/subscriptions/17fc1a23-7619-4af8-9180-e8388fc413a3","policyAssignmentParameters":{}}},{"type":"PolicyViolation","info":{"evaluationDetails":{"evaluatedExpressions":[{"result":"True","expressionKind":"Field","expression":"type","path":"type","expressionValue":"Microsoft.Compute/virtualMachineScaleSets","targetValue":"Microsoft.Compute/virtualMachineScaleSets","operator":"Equals"},{"result":"False","expressionKind":"Field","expression":"Microsoft.Compute/virtualMachineScaleSets/sku.name","path":"sku.name","expressionValue":"Standard_D2as_v4","targetValue":["Standard_D1_v2","Standard_D2_v2","Standard_D3_v2","Standard_D2s_v3","Standard_D4s_v3","Standard_B1s","Standard_B2s","Standard_B1ms","Standard_B2ms","Standard_B4ms","Standard_D2s_v2","Standard_DS1_v2","Standard_DS2_v2","Standard_DS3_v2","Standard_DS1","Standard_DS2","Standard_DS3"],"operator":"In"}]},"policyDefinitionId":"/providers/Microsoft.Management/managementGroups/udacitydedicatedsubscriptionGroup1/providers/Microsoft.Authorization/policyDefinitions/UdacityCommonPolicyDefinition","policyDefinitionName":"UdacityCommonPolicyDefinition","policyDefinitionDisplayName":"UdacityCommon policy definition","policyDefinitionEffect":"deny","policyAssignmentId":"/providers/Microsoft.Management/managementGroups/udacitydedicatedsubscriptionGroup1/providers/Microsoft.Authorization/policyAssignments/891f056473974f7289c7b312","policyAssignmentName":"891f056473974f7289c7b312","policyAssignmentDisplayName":"UdacityCommon policy definition","policyAssignmentScope":"/providers/Microsoft.Management/managementGroups/udacitydedicatedsubscriptionGroup1","policyAssignmentParameters":{}}}]}]}}
#INFO: Command ran in 11.258 seconds (init: 0.441, invoke: 10.817)
#VM scale set created: udacity-vmss
#STEP 4 - Associating NSG: udacity-vmss-nsg with subnet: udacity-vmss-vnet-subnet
#ERROR: (ResourceNotFound) The Resource 'Microsoft.Network/virtualNetworks/udacity-vmss-vnet' under resource group 'cloud-demo' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix
#Code: ResourceNotFound
#Message: The Resource 'Microsoft.Network/virtualNetworks/udacity-vmss-vnet' under resource group 'cloud-demo' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix
#INFO: Command ran in 1.463 seconds (init: 0.433, invoke: 1.030)
#NSG: udacity-vmss-nsg associated with subnet: udacity-vmss-vnet-subnet
#STEP 5 - Creating health probe tcpProbe
#ERROR: (ResourceNotFound) The Resource 'Microsoft.Network/loadBalancers/udacity-vmss-lb' under resource group 'cloud-demo' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix
#Code: ResourceNotFound
