param(
$Location,
$Prefix,
$enviornment,
$skuName,
$NumeberofSubnets = 3,
$policyTemplatePath,
$username,
$pwd,
$subscriptionName = "Visual Studio Enterprise"
)

#$username = "<your Azure account>"
$SecurePassword = ConvertTo-SecureString $pwd -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $SecurePassword

Write-Output "Loggin in Azure"

#Login-AzureRmAccount -Credential $cred 

$subscription = Select-AzureRmSubscription -Name $subscriptionName

Write-Output "Selected Subscrition ==> $($subscription.SubscriptionName)"

#Login-AzureRmAccount

#Import-Module *azurerm*

$resourceGroupName = $Prefix + "_RG" + $enviornment

Write-Output "ResouceGroup to Create $resourceGroupName"

$exist = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

if($exist){
Write-Output "ResouceGroup $resourceGroupName Already Exist..skipping creation"
}
else{
$resource = New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location -Tag @{Environment="Dev"; Company=$Prefix}
}

#$num = get-random -Maximum 100

$storageAccountName = $prefix + $enviornment
$storageAccountName = $storageAccountName.ToLower()

#$skuName = "Standard_LRS"

# Create the storage account.
$storgae = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName

if($storage){
Write-Output "Storage storageAccountName Exist"
}
else{
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName $skuName `
  }

$vnetName = $prefix + "VNet" + $enviornment

Write-Output "creating VNET"
$1 = New-AzureRmVirtualNetworkSubnetConfig -Name "Subnet_1" -AddressPrefix '172.16.1.0/24'
$2 = New-AzureRmVirtualNetworkSubnetConfig -Name 'Subnet_2' -AddressPrefix '172.16.2.0/24'
$3 = New-AzureRmVirtualNetworkSubnetConfig -Name "subnet_3" -AddressPrefix '172.16.3.0/24'

$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName -AddressPrefix '172.16.0.0/12' -Location $location -Subnet $1, $2, $3
Write-Output "VNET Created Sucssesfully"


Function CreateCustomPolicyAndAssign($resourceGroupID,$TemplatePath)
{
$definition = New-AzureRmPolicyDefinition -Name "allowed-resourcetypes" -DisplayName "Allowed resource types" -description "This policy enables you to specify the resource types that your organization can deploy." -Policy $TemplatePath
$assignment = New-AzureRmPolicyAssignment -Name 'allowed-resourcetypes-Assignment' -PolicyDefinition $definition -Scope $resourceGroupID
}

Write-Output "Assging Custom Azure Policy"

CreateCustomPolicyAndAssign -resourceGroupID $resource.ResourceId -TemplatePath "D:\Axcess\PolicyTemplate.json"

Write-Output "Custom Azure Policy applied to $resourceGroupName"