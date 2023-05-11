#!/bin/bash

uninstall() {
  echo "**************************** uninstall **************************** start "
  
  KUBERNETES_NAMESPACE=`echo ${CI_PROJECT_NAMESPACE##*/}`
  kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE}

  for f in ./**/*.yaml
  do
    kubectl delete -f $f || true
  done
  
  echo "**************************** uninstall **************************** end "
}
