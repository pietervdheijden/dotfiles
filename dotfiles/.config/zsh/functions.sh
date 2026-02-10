kubectl_context() {
  local context=$1

  if [[ -n "$context" ]]; then
    kubectl config use-context "$context"
    return
  fi

  context=$(kubectl config get-contexts -o name | fzf --prompt="Select Kubernetes context: ")

  if [[ -n "$context" ]]; then
    kubectl config use-context "$context"
  fi
}


kubectl_namespace() {
  local namespace=$1

  if [[ -n "$namespace" ]]; then
    kubectl config set-context --current --namespace "$namespace"
    return
  fi

  namespace=$(kubectl get namespaces -o name | sed 's|namespace/||' | fzf --prompt="Select Kubernetes namespace: ")

  if [[ -n "$namespace" ]]; then
    kubectl config set-context --current --namespace "$namespace"
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

kubectl_debug_node() {
  local node=$1

  if [[ -z "$node" ]]; then
    node=$(kubectl get nodes -o name | sed 's|node/||' | fzf --prompt="Select node: ")
  fi

  if [[ -z "$node" ]]; then
    return 1
  fi

  kubectl debug "node/$node" -it --image=docker.io/alpine:3.13 --profile=sysadmin -- nsenter -t 1 -m -u -i -n /bin/sh
}

kubectl_debug_node_by_pod() {
  local pod=$1

  if [[ -z "$pod" ]]; then
    pod=$(kubectl get pods -o name | sed 's|pod/||' | fzf --prompt="Select pod: ")
  fi

  if [[ -z "$pod" ]]; then
    return 1
  fi

  local node
  node=$(kubectl get pod "$pod" -o jsonpath='{.spec.nodeName}')

  if [[ -z "$node" ]]; then
    echo "Error: Could not find node for pod '$pod'"
    return 1
  fi

  echo "Pod '$pod' is running on node '$node'"
  kubectl debug "node/$node" -it --image=docker.io/alpine:3.13 --profile=sysadmin -- nsenter -t 1 -m -u -i -n /bin/sh
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

tolower() {
  tr '[:upper:]' '[:lower:]'
}

toupper() {
  tr '[:lower:]' '[:upper:]'
}

uuidlc() {
  uuidgen | tolower
}
