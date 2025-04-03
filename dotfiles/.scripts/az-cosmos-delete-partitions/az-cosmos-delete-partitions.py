from azure.cosmos import CosmosClient, exceptions
from azure.identity import AzureCliCredential
import time
import os

def delete_partitions(container, partition_key_prefix):
    # Query to get all partition keys starting with partition_key_prefix
    query = f"SELECT DISTINCT c.partitionKey FROM c WHERE STARTSWITH(c.partitionKey, '{partition_key_prefix}')"
    print(f"Query: {query}")

    # Execute query to get partition keys
    partition_keys = list(container.query_items(query, enable_cross_partition_query=True))

    # Sort partition keys
    partition_keys = sorted(partition_keys, key=lambda x: x['partitionKey'])
    
    # Print the number of partition keys to be deleted
    num_partition_keys = len(partition_keys)
    print(f"Number of partition keys to be deleted: {num_partition_keys}")

    retry_delay = 30  # seconds
    current_index = 0
    while True:
        try:
            for index in range(current_index, len(partition_keys)):
                item = partition_keys[index]
                partition_key = item['partitionKey']

                print(f"Deleting partition ({current_index}/{num_partition_keys}) with key: {partition_key}")

                # Delete all items with this partition key
                container.delete_all_items_by_partition_key(partition_key)
                
                print(f"Deleted partition ({current_index}/{num_partition_keys}) with key: {partition_key}")

                current_index = index + 1  # Update the current index

            print("Partition deletion process completed.")
            break  # Exit the loop if all partitions are processed

        except exceptions.CosmosHttpResponseError as e:
            if e.status_code == 429:  # TooManyRequests
                print(f"Rate limit exceeded. Waiting for {retry_delay} seconds before retrying... (Resuming from index {current_index})")
                time.sleep(retry_delay)
                # The loop will continue from current_index on the next iteration
            else:
                print(f"An error occurred: {str(e)}")
                break  # Exit the loop for non-429 errors

        except Exception as e:
            print(f"An error occurred: {str(e)}")
            break

def main():
    # Load Cosmos DB connection details from environment variables
    endpoint = os.environ.get('COSMOS_ENDPOINT')
    database_name = os.environ.get('COSMOS_DATABASE')
    container_name = os.environ.get('COSMOS_CONTAINER')
    partition_key_prefix = os.environ.get('PARTITION_KEY_PREFIX')

    # Check if all required environment variables are set
    required_vars = ['COSMOS_ENDPOINT', 'COSMOS_DATABASE', 'COSMOS_CONTAINER', 'PARTITION_KEY_PREFIX']
    missing_vars = [var for var in required_vars if not os.environ.get(var)]
    if missing_vars:
        raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")

    # Initialize the Azure CLI credential
    credential = AzureCliCredential()

    # Initialize the Cosmos client using Azure CLI authentication
    client = CosmosClient(endpoint, credential=credential)

    # Get a reference to the database and container
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    # Delete partitions
    delete_partitions(container, partition_key_prefix)

if __name__ == "__main__":
    main()

