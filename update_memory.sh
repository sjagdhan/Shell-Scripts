#!/bin/bash

NAMESPACE="$1"
FILE="deployments_$1_orig.yaml"
UPDTAED_FILE="deployments_$1_updated.yaml"

# Get all deployments in the namespace
kubectl get deployments -n $NAMESPACE -o yaml > $FILE

# Function to multiply memory values by 1.5
multiply_memory() {
  awk '/memory:/ { 
    mem=$2; 
    if (mem ~ /Mi$/) { 
      mem_val=substr(mem, 1, length(mem)-2); 
      new_mem_val=int(mem_val * 1.5); 
      print "              memory: " new_mem_val "Mi"; 
    } else if (mem ~ /Gi$/) { 
      mem_val=substr(mem, 1, length(mem)-2); 
      new_mem_val=int(mem_val * 1.5); 
      print "              memory: " new_mem_val "Gi"; 
    } else { 
      print $0; 
    } 
  } !/memory:/ { print $0 }'
}

# Edit the deployment to multiply limit.memory & request.memory by 1.5
sed -i '/limits:/,/requests:/ { /memory:/!b; n; s/.*/&/; }' $FILE
sed -i '/requests:/,/limits:/ { /memory:/!b; n; s/.*/&/; }' $FILE

# Apply the multiply_memory function to the file
multiply_memory < $FILE > temp.yaml && mv temp.yaml $UPDTAED_FILE

# Apply the updated deployments
kubectl apply -f $UPDTAED_FILE > $1_apply_logs.log