#!/bin/bash

remove_old_jobs() {
  echo "**************************** remove old jobs **************************** start "

  KUBERNETES_NAMESPACE=`echo ${CI_PROJECT_NAMESPACE##*/}`
  kubectl config set-context --current --namespace=${KUBERNETES_NAMESPACE}

  cd old_manifests
  for FILE_NAME in *
  do
    if grep -q "kind: Job" "$FILE_NAME"; then
      JOB_NAME=`yq -o=json '.' $FILE_NAME | jq -r '.metadata.name'`
      kubectl delete job $JOB_NAME  || true
    fi
  done

  cd ../new_manifests
  for FILE_NAME in *
  do
    if grep -q "kind: Job" "$FILE_NAME"; then
      JOB_NAME=`yq -o=json '.' $FILE_NAME | jq -r '.metadata.name'`
      kubectl delete job $JOB_NAME  || true
    fi
  done
  
  cd ..
  
  echo "**************************** remove old jobs **************************** end"
}
