#!/usr/bin/env bash

# Kubectl
alias k="kubectl"
alias kx='kubectl_context'
alias kn='kubectl_namespace'
alias kgi='kubectl get ingress'
alias kgio='kubectl get ingress -o yaml'
alias kgn='kubectl get namespace'
alias kgnp='kubectl get netpol'
alias kgp='kubectl get pod'
alias kgs='kubectl get service'
alias kge="kubectl get events --sort-by='.lastTimestamp'"
alias kgpo='kubectl get pod -o yaml'
alias ksd0='kubectl scale deployment --replicas=0'
alias ksd1='kubectl scale deployment --replicas=1'
alias ksd2='kubectl scale deployment --replicas=2'
alias ksd3='kubectl scale deployment --replicas=3'
alias ksd4='kubectl scale deployment --replicas=4'
alias ksd5='kubectl scale deployment --replicas=5'
alias ksd6='kubectl scale deployment --replicas=6'
alias kdelpe='kubectl_delete_error_pods_in_current_namespace'
alias kdelpea='kubectl_delete_error_pods_in_all_namespaces'
alias ktp='kubectl top pods'
alias ktpa='kubectl top pods -A'
alias ktn='kubectl top nodes'
alias kgd='kubectl get deployment'
alias kgdo='kubectl get deployment -o yaml'
alias kgda='kubectl get deployment -A'

# Helm
alias h="helm"

# Terraform
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init -upgrade'
alias tfia='terraform init -upgrade && terraform apply'
alias tfiaa='terraform init -upgrade && terraform apply -auto-approve'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfm='terraform fmt -recursive'
alias tfd='terraform destroy'
alias tfid='terraform init -upgrade && terraform destroy'

# Terramate
alias tm='terramate'
alias tmg='terramate generate'

# Vim
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# Python
alias py='python3'
alias python='python3'
alias pip='pip3'
alias pir='pip install -r requirements.txt'

# LazyGit
alias lg='lazygit'

# Base64
alias b64='base64'
alias b64d='base64 -d'

# Tmux
alias t='tmux'

# Maven
alias mvn11='JAVA_HOME=/usr/lib/jvm/java-11-openjdk mvn'
alias mvn17='JAVA_HOME=/usr/lib/jvm/java-17-openjdk mvn'

# Other
alias pp="sed 's/\\\\n/\'$'\\n''/g'" # pretty print
alias cl='clear'
alias cls='clear'
