#!/bin/bash

security_check() {

  echo "**************************** security check **************************** start "

  set -xe

  mv /app/cd-assets/helm-security-policies policy

  for f in new_manifests/*
  do
    conftest test $f
  done

  #if [[ "$CI_PROJECT_NAMESPACE" == *"cd/4021"* ]]; then
  #
  #  if ls ./new_manifests/networkpolicy-* 1> /dev/null 2>&1; then
  #    echo "network policy exist"
  #  else
  #    echo "error: network policy does not exist"
  #    exit 1
  #  fi
  #
  #fi
  
  echo "**************************** security check **************************** end "
}
