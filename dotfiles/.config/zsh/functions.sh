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

kubectl_delete_error_pods_in_current_namespace() {
  echo "Deleting all error pods in current namespace..."
  kubectl get pods | grep Error | awk '{print $1}' | xargs -r -n1 sh -c 'kubectl delete pod "$0"'
}

kubectl_delete_error_pods_in_all_namespaces() {
  echo "Deleting all error pods in all namespaces..."
  kubectl get pods -A | grep Error | awk '{print $1, $2}' | xargs -r -n2 sh -c 'kubectl delete pod "$1" -n "$0"'
}

az_sb_receive_and_delete_messages() {
  local fqn=$1
  local queue_name=$2
  local dlq=$3

  FQN=$fqn QUEUE_NAME=$queue_name DLQ=$dlq $HOME/bin/az-sb-receive-and-delete-messages/run.sh
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
  $HOME/bin/az-cosmos-delete-partitions/run.sh
}

# Check if app credentials are expired or will expire in the next 60 days
az_ad_app_check_credential_expiry() {
  # Get current date and future date (60 days from now) in ISO 8601 format
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  future_date=$(date -u -d "+60 days" +"%Y-%m-%dT%H:%M:%SZ")

  # Fetch service principals and process with jq
  result=$(az ad app list --all --query "[?passwordCredentials].{appId: appId, displayName: displayName, passwordCredentials: passwordCredentials}" -o json | 
    jq --arg current_date "$current_date" --arg future_date "$future_date" -c '
      .[] |
      {
        appId: .appId,
        displayName: .displayName,
        expiredCredentials: [
          .passwordCredentials[] |
          select(.endDateTime < $current_date) |
          {keyId: .keyId, endDateTime: .endDateTime}
        ],
        expiringSoonCredentials: [
          .passwordCredentials[] |
          select(.endDateTime >= $current_date and .endDateTime <= $future_date) |
          {keyId: .keyId, endDateTime: .endDateTime}
        ]
      } |
      select((.expiredCredentials | length > 0) or (.expiringSoonCredentials | length > 0))
    '
  )

  # Check if the result is non-empty
  if [ -n "$result" ]; then
    echo "There are apps with expired or soon-to-expire credentials."
    echo "$result" | jq .
  else
    echo "No apps have expired or soon-to-expire credentials."
  fi
}

# Check if service principal credentials are expired or will expire in the next 60 days
az_ad_sp_check_credential_expiry() {
  # Get current date and future date (60 days from now) in ISO 8601 format
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  future_date=$(date -u -d "+60 days" +"%Y-%m-%dT%H:%M:%SZ")

  # Fetch service principals and process with jq
  result=$(az ad sp list --all --query "[?passwordCredentials].{appId: appId, displayName: displayName, passwordCredentials: passwordCredentials}" -o json | 
    jq --arg current_date "$current_date" --arg future_date "$future_date" -c '
      .[] |
      {
        appId: .appId,
        displayName: .displayName,
        expiredCredentials: [
          .passwordCredentials[] |
          select(.endDateTime < $current_date) |
          {keyId: .keyId, endDateTime: .endDateTime}
        ],
        expiringSoonCredentials: [
          .passwordCredentials[] |
          select(.endDateTime >= $current_date and .endDateTime <= $future_date) |
          {keyId: .keyId, endDateTime: .endDateTime}
        ]
      } |
      select((.expiredCredentials | length > 0) or (.expiringSoonCredentials | length > 0))
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
