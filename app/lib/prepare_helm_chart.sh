#!/bin/bash

prepare_helm_chart() {

  echo "**************************** prepare helm chart **************************** start "

  cat ${LAN_CA} >> /etc/ssl/certs/ca-certificates.crt
  helm registry login -u ${DOCKERREPO_USERNAME} -p ${DOCKERREPO_PASSWORD} ${DOCKERREPO_ADDRESS}
  
  ########## get desiered helm chart ##########
  VERSION=`cat version`
  if [ "$VERSION" == "latest-release" ]; then
    response=`curl --user ${DOCKERREPO_USERNAME}:${DOCKERREPO_PASSWORD} https://${DOCKERREPO_ADDRESS}/v2/helm/${CI_PROJECT_NAME}/tags/list`
    VERSION=`echo $response | jq -r '.tags | .[] | select( test("SNAPSHOT") | not)' | sort -t "." -k1,1n -k2,2n -k3,3n | tail -1`
  elif [ $VERSION == "latest-snapshot" ]; then
    response=`curl --user ${DOCKERREPO_USERNAME}:${DOCKERREPO_PASSWORD} https://${DOCKERREPO_ADDRESS}/v2/helm/${CI_PROJECT_NAME}/tags/list`
    VERSION=`echo $response | jq -r '.tags | .[] | select( test("SNAPSHOT"))' | sort -t "." -k1,1n -k2,2n -k3,3n | tail -1`
  fi

  chmod -R +x /app/cd-assets/kustomize
  mv /app/cd-assets/kustomize .
  INSTALLATION_ARGS="--post-renderer=./kustomize/hook.sh"
  
  ########## helm pull and prepare ##########
  helm pull oci://${DOCKERREPO_ADDRESS}/helm/${CI_PROJECT_NAME} --version ${VERSION} --untar --untardir helm-chart
  cp -r config/. ./helm-chart/${CI_PROJECT_NAME}/values || true
  if [[ -f "./config/values.yaml" ]]; then 
    cp ./config/values.yaml ./helm-chart/${CI_PROJECT_NAME}/custom-values.yaml
    rm ./helm-chart/${CI_PROJECT_NAME}/values/values.yaml
    INSTALLATION_ARGS="--values ./helm-chart/${CI_PROJECT_NAME}/custom-values.yaml $INSTALLATION_ARGS"
  fi

  ############## generate new manifests ##############
  KUBERNETES_NAMESPACE=`echo ${CI_PROJECT_NAMESPACE##*/}`

  helm template --debug -n ${KUBERNETES_NAMESPACE} ${CI_PROJECT_NAME} ./helm-chart/${CI_PROJECT_NAME} --values ./helm-chart/${CI_PROJECT_NAME}/values.yaml $INSTALLATION_ARGS > all_manifests.yaml

  kubectl-slice --input-file=all_manifests.yaml --output-dir=new_manifests

  if [ -d "./helm-chart/${CI_PROJECT_NAME}/crds" ]
  then
    cp -r ./helm-chart/${CI_PROJECT_NAME}/crds new_manifests
  fi

  ############# get old manifests ########################

  status_code=$(curl --write-out %{http_code} -X GET -H "JOB-TOKEN: $CI_JOB_TOKEN" --silent --output manifests.tar.gz ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/kubernetes-manifests/latest/manifests.tar.gz)

  if [[ "$status_code" == 404 ]]; then
    echo "deployed manifests does not exists"
    mkdir old_manifests
  else
    tar -xvzf manifests.tar.gz
    mv manifests old_manifests
  fi
  
  echo "**************************** prepare helm chart **************************** end "
}
