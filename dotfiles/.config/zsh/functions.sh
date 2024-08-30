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

az_receive_and_delete_sb_messages() {
  local fqn=$1
  local queue_name=$2
  local dlq=$3

  FQN=$fqn QUEUE_NAME=$queue_name DLQ=$dlq $HOME/.scripts/az-receive-and-delete-sb-messages/run.sh
}
