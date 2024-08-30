import os
from azure.servicebus import ServiceBusClient
from azure.identity import DefaultAzureCredential

def receive_and_delete_all_messages(servicebus_client, queue_name):
    with servicebus_client.get_queue_receiver(queue_name) as receiver:
        while True:
            received_msgs = receiver.receive_messages(max_message_count=10000, max_wait_time=30)
            print(f"Received {len(received_msgs)} messages")
            if not received_msgs:
                print("No more messages left in the queue.")
                break
            for msg in received_msgs:
                #print(f"Received message: {str(msg)}")
                # Complete the message, which deletes it from the queue
                receiver.complete_message(msg)
            print(f"Completed {len(received_msgs)} messages.")

def main():
    # Get fqn and queue name from environment variables
    fully_qualified_namespace = os.getenv('FQN')
    queue_name = os.getenv('QUEUE_NAME')
    dlq = os.getenv('DLQ', 'false').lower() in ('true', '1', 't', 'yes')
    
    if not fully_qualified_namespace:
        raise ValueError("FQN environment variable must be set.")

    if not fully_qualified_namespace.endswith(".servicebus.windows.net"):
        fully_qualified_namespace += ".servicebus.windows.net"

    if not queue_name:
        raise ValueError("QUEUE_NAME environment variable must be set.")

    if dlq:
        queue_name += "/$DeadLetterQueue"

    # Create a ServiceBusClient object to interact with the Service Bus
    credential = DefaultAzureCredential()
    servicebus_client = ServiceBusClient(fully_qualified_namespace, credential)

    try:
        # Receive and delete all messages
        receive_and_delete_all_messages(servicebus_client, queue_name)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Close the client
        servicebus_client.close()

if __name__ == "__main__":
    main()

