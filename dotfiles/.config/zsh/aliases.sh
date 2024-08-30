#!/usr/bin/env bash

# Kubectl
alias k="kubectl"
alias kx='kubectl_context'
alias kn='kubectl_namespace'
alias kgi='kubectl get ingress'
alias kgn='kubectl get namespace'
alias kgnp='kubectl get netpol'
alias kgp='kubectl get pod'
alias kgs='kubectl get service'
alias kge="kubectl get events --sort-by='.lastTimestamp'"

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

# Python
alias py='python3'
alias python='python3'
alias pip='pip3'

# Other
alias pp="sed 's/\\\\n/\'$'\\n''/g'" # pretty print
alias cl='clear'
alias cls='clear'
