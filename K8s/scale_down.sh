#!/bin/bash

NAMESPACE="$1"
for deploy in $(kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}'); do
  kubectl scale deployment $deploy --replicas=0 -n $NAMESPACE
done