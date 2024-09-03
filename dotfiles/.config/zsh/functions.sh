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
