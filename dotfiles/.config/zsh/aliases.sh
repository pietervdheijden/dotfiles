#!/usr/bin/env bash

# Kubectl
alias k="kubectl"
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'

# Terraform
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init -upgrade'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfm='terraform fmt -recursive'

# Terramate
alias tm='terramate'
alias tmg='terramate generate'

# Other
alias pp="sed 's/\\\\n/\'$'\\n''/g'" # pretty print
