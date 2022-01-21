#Your subscription ID - get from Azure portal
$subscriptionId = ""
# Your resource group name - get from Azure portal
$resourceGroupName = ""
#storage account connection string - get from configuration.txt file
$storageConnString = ""

#function app name (not the name of the function IN the function app) - get from Azure portal
$functionAppName = ""

#function package URI
# NOTE: When you create a Shared Access Key protected file in Azure storage, the URI will contain '&' characters
# To be able to parse the whole URI correctly you need to make sure the entire string is surrounded by single quotes '
# and then each & character surrounded by double quotes
$functionPackageURI = 'https://lwworkstorage.blob.core.windows.net/serverlessworkshop/package.zip?st=2019-07-28T19%3A50%3A58Z"&"se=2019-12-29T19%3A50%3A00Z"&"sp=rl"&"sv=2018-03-28"&"sr=b"&"sig=%2BH6WQFV2pUwpRner3%2F%2FSUqxWxiCYX4VUII9Eva4uZzg%3D'

#CosmosDB Settings
# This is the name of the CosmosDB account - get from Azure portal
$cosmosDBAcctName = ""
# Authorization Key - get from configuration.txt file
$cosmosDBPrimaryKey = ""
# CosmosDB URI - get from configuration.txt file
$cosmosEndpoint = ""


# ***********************************************
# ***********************************************
# ***********************************************
# Do not change any settings past this point
# Name of the database the Azure Function will use
# ***********************************************
# ***********************************************
$cosmosDBDatabaseName = "dbOrders"
# Name of the collection in the database
$cosmosDBCollectionName = "orders"
# Name of the partition in the collection
$cosmosDBPartition = "/orders"


#This section is used specifically for your app settings
# for an app setting there is a <name>=<value> pair
#The URI to the Azure function package
$app_websiteRunFromPackage = 'WEBSITE_RUN_FROM_PACKAGE=' + $functionPackageURI


# URI to your CosmosDB account
$app_cosmosDBURI = "cosmosURI=" + $cosmosEndpoint
#cosmosDB collection name
$app_collectionName = "collectionName=" + $cosmosDBCollectionName
#cosmosDB database name
$app_databaseName = "databaseName=" + $cosmosDBDatabaseName
#cosmosDB Primary Key
$app_authorizationKey = "authorizationKey=" + $cosmosDBPrimaryKey
# AppSetting used with WEBSITE_CONTENTAZUREFILECONNECTIONSTRING ~ your function app name
$app_websiteContentShare = "WEBSITE_CONTENTSHARE=" + $functionAppName
#Place the storage account connection string here
$app_websiteContentAzureFileConnectionString = "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING=" + $storageConnString
$app_azureWebJobsStorage = "AzureWebJobsStorage=" + $storageConnString
$app_azureWebJobsDashboard = "AzureWebJobsDashboard=" + $storageConnString

az login

#set your Azure subscription
az account set --subscription $subscriptionId

#Configure your function app
az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_cosmosDBURI

# In this command, both the WEBSITE_CONTENTSHARE (~name of your functionapp) and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING (storage acct
# connection string) MUST BE TOGETHER. One cannot be created without the other
az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_websiteContentShare $app_websiteContentAzureFileConnectionString

az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_azureWebJobsStorage
az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_azureWebJobsDashboard
az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_authorizationKey

az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_websiteRunFromPackage

az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_collectionName
az functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings $app_databaseName

# Create the CosmosDB database and collection
az cosmosdb database create --resource-group $resourceGroupName --name $cosmosDBAcctName --db-name $cosmosDBDatabaseName
az cosmosdb collection create --resource-group $resourceGroupName --collection-name $cosmosDBCollectionName --name $cosmosDBAcctName --db-name `
$cosmosDBDatabaseName --partition-key-path $cosmosDBPartition --throughput 400


$app_websiteRunFromPackage = 'WEBSITE_RUN_FROM_PACKAGE=' + $functionPackageURI
$arguments = "functionapp config appsettings set --resource-group $resourceGroupName --name $functionAppName --settings "
$arguments += $app_websiteRunFromPackage

Start-Process -FilePath "az" -ArgumentList $arguments -Wait -NoNewWindow