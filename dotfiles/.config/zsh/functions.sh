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

receive_and_delete_az_sb_messages() {
  local connection_str=$1
  local queue_name=$2
  local dlq=$3

  CONNECTION_STR=$connection_str QUEUE_NAME=$queue_name DLQ=$dlq py $HOME/.scripts/receive-and-delete-az-sb-messages.py
}
