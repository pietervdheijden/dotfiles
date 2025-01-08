kubectl_context() {
  local context=$1
  if [ "$context" ]; then
    kubectl config use-context $context
  else
    kubectl config current-context
  fi
}

kubectl_namespace() {
  local namespace=$1
  if [ "$namespace" ]; then
    kubectl config set-context --current --namespace $namespace
  else
    kubectl config view --minify | grep namespace | cut -d" " -f6
  fi
}

az_sb_receive_and_delete_messages() {
  local fqn=$1
  local queue_name=$2
  local dlq=$3

  FQN=$fqn QUEUE_NAME=$queue_name DLQ=$dlq $HOME/.scripts/az-sb-receive-and-delete-messages/run.sh
}

az_cosmos_delete_partitions() {
  local endpoint=$1
  local database_name=$2
  local container_name=$3
  local partition_key_prefix=$4

  COSMOS_ENDPOINT=$endpoint \
  COSMOS_DATABASE=$database_name \
  COSMOS_CONTAINER=$container_name \
  PARTITION_KEY_PREFIX=$partition_key_prefix \
  $HOME/.scripts/az-cosmos-delete-partitions/run.sh
}

az_find_expired_sp_credentials() {
  # Get current date and future date (30 days from now) in ISO 8601 format
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  future_date=$(date -u -d "+60 days" +"%Y-%m-%dT%H:%M:%SZ")

  # Fetch service principals and process with jq
  result=$(az ad sp list --all --query "[?passwordCredentials].{DisplayName: displayName, PasswordCredentials: passwordCredentials}" -o json | 
    jq --arg current_date "$current_date" --arg future_date "$future_date" -c '
      .[] |
      {
        DisplayName: .DisplayName,
        ExpiredCredentials: [
          .PasswordCredentials[] |
          select(.endDateTime < $current_date) |
          {endDateTime: .endDateTime, keyId: .keyId}
        ],
        ExpiringSoonCredentials: [
          .PasswordCredentials[] |
          select(.endDateTime >= $current_date and .endDateTime <= $future_date) |
          {endDateTime: .endDateTime, keyId: .keyId}
        ]
      } |
      select((.ExpiredCredentials | length > 0) or (.ExpiringSoonCredentials | length > 0))
    '
  )

  # Check if the result is non-empty
  if [ -n "$result" ]; then
    echo "There are service principals with expired or soon-to-expire credentials."
    echo "$result" | jq .
    echo "Either renew the credentials with Terraform or delete them by running: 'az ad sp credential delete --id <appId> --key-id <keyId>'"
  else
    echo "No service principals have expired or soon-to-expire credentials."
  fi
}
