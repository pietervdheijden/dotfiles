#!/usr/bin/env bash

# Kubectl
alias k="kubectl"
alias kx='kubectl_context'
alias kn='kubectl_namespace'

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

# Vim
alias vim='nvim'
alias nv='nvim'

# Other
alias pp="sed 's/\\\\n/\'$'\\n''/g'" # pretty print
