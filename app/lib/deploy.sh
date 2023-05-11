#!/bin/bash

deploy() {
  echo "**************************** deploy **************************** start "
  
  KUBERNETES_NAMESPACE=`echo ${CI_PROJECT_NAMESPACE##*/}`

  kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE}

  kubectl create namespace ${KUBERNETES_NAMESPACE} || true

  kubectl create secret docker-registry regcred --docker-server=${DOCKERREPO_ADDRESS} --docker-username=${DOCKERREPO_USERNAME} --docker-password=${DOCKERREPO_PASSWORD}  --dry-run -o yaml | kubectl apply -f -
  
  ############## remove old manifests that is not exists in new manifests ##############
  DELETED_MANIFESTS=`find ./old_manifests/ ./new_manifests/ ./new_manifests/ -printf '%P\n' | sort | uniq -u`
  for manifest in $DELETED_MANIFESTS
  do
      echo "deleting manifest $manifest"
      kubectl delete -f old_manifests/$manifest  || true
  done
  
  ############## deploy to kubernetes ##############
  if [ -d "./new_manifests/crds" ]
  then 
    for f in new_manifests/crds/*
    do
      kubectl apply -f $f 
    done
  fi

  for f in new_manifests/*
  do
    kubectl apply -f $f 
  done

  ############## upload new manifests to gitlab for future pipeline execution ##############
  mv new_manifests manifests
  tar -cvzf manifests.tar.gz manifests
  curl --header "JOB-TOKEN: $CI_JOB_TOKEN" --upload-file manifests.tar.gz "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/kubernetes-manifests/latest/manifests.tar.gz"
  
  echo "**************************** deploy **************************** end "
}
