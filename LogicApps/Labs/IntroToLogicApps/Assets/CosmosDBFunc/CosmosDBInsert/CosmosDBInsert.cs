using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents;
using Microsoft.Extensions.Configuration;

namespace CosmosDBInsert
{
    public static class CosmosDBInsert
    {
        private static IDocumentClient client;
        private static string cosmosURI;
        private static string authKey;
        private static string databaseName;
        private static string collectionName;

        [FunctionName("CosmosDBInsert")]
        public static async Task Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequestMessage req,
            ILogger log, ExecutionContext context)
        {
            SetupConfig(context);

            log.LogInformation("C# HTTP trigger function processed a request.");

            // Read the data in from the JSON document
            string data = await req.Content.ReadAsStringAsync();
            dynamic mydata = JsonConvert.DeserializeObject(data);

            try
            {
                // Create a client to connect to document DB. The URI and auth key
                // will come from the functions app settings
                client = new DocumentClient(new System.Uri(cosmosURI),authKey);

                // Get the collection we are going to put the data in
                // the databaseName and collectionName will come from the functions appsettings
                var collectionLink = UriFactory.CreateDocumentCollectionUri(databaseName, collectionName);
            
                // Insert the document in to the database collection
                Document created = await client.CreateDocumentAsync(collectionLink, mydata);
            }
            catch (Exception ex)
            {
                log.LogError("Exception thrown in document write: {0}", ex.Message);
            }

        }
        private static void SetupConfig(ExecutionContext context)
        {
            // This ConfigBuilder will only be used when running locally
            var config = new ConfigurationBuilder()
        .SetBasePath(context.FunctionAppDirectory)
        .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
        .AddEnvironmentVariables()
        .Build();

            cosmosURI = config["cosmosURI"];
            authKey = config["authorizationKey"];
            databaseName = config["databaseName"];
            collectionName = config["collectionName"];

        }
    }
}
