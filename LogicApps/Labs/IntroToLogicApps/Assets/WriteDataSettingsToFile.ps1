# This script will output connection strings and keys for resources you have in Azure
# Run Login-AzureRmAccount first before running this script and from that output, you can get your Subscription ID
# Set the local parameters to your values

####################################################
# Input information for the following three fields 
####################################################
# Initial used when creating resources:
# USE ONLY lowercase CHARACTERS:
$YourInitials = ""
#Resource group name: 
$ResourceGroupName = ""
#Set the Azure Subscription Id: 
$subscriptionId = "" 

# **********************************************************************************************
# Should we bounce this script execution?
# **********************************************************************************************
if (($YourInitials -eq '') -or `
    ($ResourceGroupName -eq '') -or `
	($subscriptionId -eq ''))
{
	Write-Host 'You must tells us your Initials, Resource Group Name and Subscription ID, before executing' -foregroundcolor Yellow
	exit
}


####################################################
# Modify the file name and location 
####################################################
$filePath="c:\serverless\"
$fileName="configuration.txt"

####################################################
# Switch to write configuration values to the screen.
# Set to False by default. 
# Set to 'true' to write values to screen.
####################################################
$WriteToScreen= "false"

####################################################
# DO NOT CHANGE VALUES BENEATH THIS LINE
####################################################

#If user not logged into Azure account, redirect to login screen
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) 
{
    Login-AzureRmAccount 
    $VerbosePreference = "SilentlyContinue"
}


#Helpers
$quote='"'
$colon=':'
$comma=','
$https="https://"
$suffix="serverless"

#CosmosDB database name
$DBName = -join($YourInitials,'-serverless')

#If more than one under your account
Select-AzureRmSubscription -SubscriptionId $subscriptionId
#Verify Current Subscription
Get-AzureRmSubscription –SubscriptionId $subscriptionId

# Create new file
$File = New-Item $filePath$fileName -type file -force

Write-Host "----------------------------------------------------------------------------------------------"
Write-Host " Processing, please be patient..."                                     
Write-Host "----------------------------------------------------------------------------------------------" 
Write-Host 

Add-Content -Path $File  "//----------------------------------------------------------------------------------------------"  
Add-Content -Path $File  "//You will need the values below to perform your hands-on lab"  
Add-Content -Path $File  "//----------------------------------------------------------------------------------------------"  
Add-Content -Path $File  " " 
Write-Host

#Get the Storage account name 
#This is your initials  
#https://stackoverflow.com/questions/3896258/how-do-i-output-text-without-a-newline-in-powershell


#Build storage acccount settings
$storageAccountHeader="StorageAccount"
$storageKeyHeader="StorageKey"
$storageAccount="$storageAccountHeader$colon$quote$YourInitials$suffix$quote"


Add-Content -Path $File  "//Azure Storage Account Name" 
Add-Content -Path $File  $storageAccount 
Add-Content -Path $File  " " 

if ($WriteToScreen -eq "True") 
{
    Write-Host "//Azure Storage Account Name"
    Write-Host $storageAccount 
    Write-Host 
}

#Get the Storage account key - primary key 
$accountName = "$YourInitials$suffix"
$storagePrimKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $YourInitials$suffix).Value[0] 
$storageAccountKey="$storageKeyHeader$colon$quote$storagePrimKey$quote"

Add-Content -Path $File  "//----------------------------------------------------------------------------------------------"  
Add-Content -Path $File  "//Azure Storage Account Key" 
Add-Content -Path $File  "//----------------------------------------------------------------------------------------------"  

Add-Content -Path $File  $storageAccountKey 
Add-Content -Path $File  " " 

if ($WriteToScreen -eq "True") 
{
    Write-Host "//Azure Storage Account Key"
    Write-Host $storageAccountKey
    Write-Host 
}

Add-Content -Path $File  "//-----------------------------------------------------------"  
Add-Content -Path $File  "//Azure Storage account connection string" 
Add-Content -Path $File  "//-----------------------------------------------------------"  

#Following code fetches storage account connection string
Add-Content -Path $File  "//Azure Storage Connection string" 
$storageConnectionString= "StorageConnectionString: DefaultEndpointsProtocol=https;AccountName=$accountName;AccountKey=$storagePrimKey;EndpointSuffix=core.windows.net"
Add-Content -Path $File  $storageConnectionString 
Add-Content -Path $File  " "

# Get the Queue connection string
$queuePrefix = "ServiceBusPublisherConnectionString"
$queue = (Get-AzureRmServiceBusKey -ResourceGroupName $ResourceGroupName -Namespace $YourInitials-serverless `
-Name RootManageSharedAccessKey).PrimaryConnectionString
$queueString="$queuePrefix$colon$quote$queue$quote"

Add-Content -Path $File  "//-----------------------------------------------------------"  
Add-Content -Path $File  "//Azure Service Bus Queue Connection String" 
Add-Content -Path $File  "//-----------------------------------------------------------"  

Add-Content -Path $File  $queueString 
Add-Content -Path $File  " " 

if ($WriteToScreen -eq "True") 
{
    Write-Host "//Azure Service Bus Queue Connection String"
    Write-Host $queueString
    Write-Host 
}

#Get Cosmos connection information
# Get the list of keys for the CosmosDB database
$myKeys = Invoke-AzureRmResourceAction -Action listKeys `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2016-03-31" `
    -ResourceGroupName $ResourceGroupName `
    -Name $DBName -Force
  
# pull out the primary key
$primaryKey = $myKeys.primaryMasterKey;

# Get the CosmosDB connection URI
$cosmosUriHeader="CosmosEndpoint"
$cosmosUriString="$YourInitials-serverless.documents.azure.com:443"
$cosmosUri="$cosmosUriHeader$colon$quote$https$cosmosUriString$quote"

Add-Content -Path $File  "//-----------------------------------------------------------"  
Add-Content -Path $File  "//Azure Cosmos DB Connection URI" 
Add-Content -Path $File  "//-----------------------------------------------------------"  

Add-Content -Path $File  $cosmosUri 
Add-Content -Path $File  " " 

if ($WriteToScreen -eq "True") 
{
    Write-Host "//Azure Cosmos DB Connection URI"
    Write-Host $cosmosUri 
    Write-Host 
}

# Get the CosmosDB Primay Key
$cosmosKeyHeader="CosmosPrimaryKey"
$cosmosKey="$cosmosKeyHeader$colon$quote$primaryKey$quote"

Add-Content -Path $File  "//-----------------------------------------------------------"  
Add-Content -Path $File  "//Azure Cosmos DB Primary Key" 
Add-Content -Path $File  "//-----------------------------------------------------------"  

Add-Content -Path $File  $cosmosKey 
Add-Content -Path $File  " " 

if ($WriteToScreen -eq "True") 
{
    Write-Host "//Azure Cosmos DB Primary Key"
    Write-Host $cosmosUricosmosKey 
    Write-Host 
}

Write-Host "**********************************************************************************************" 
Write-Host "*                                                                                            *" 
Write-Host "* Done                                                                                       *" 
Write-Host "*                                                                                            *" 
Write-Host "* Open '$File' and use these values in your hands-on lab                                     *" 
Write-Host "*                                                                                            *" 
Write-Host "**********************************************************************************************" 