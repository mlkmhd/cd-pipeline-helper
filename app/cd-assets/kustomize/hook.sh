#!/bin/bash
cat <&0 > kustomize/all.yaml
kubectl kustomize ./kustomize
