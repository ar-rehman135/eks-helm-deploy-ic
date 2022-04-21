#!/usr/bin/env bash

# Login to Kubernetes Cluster.
# UPDATE_KUBECONFIG_COMMAND="aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
# if [ -n "$CLUSTER_ROLE_ARN" ]; then
#     UPDATE_KUBECONFIG_COMMAND="${UPDATE_KUBECONFIG_COMMAND} --role-arn=${CLUSTER_ROLE_ARN}"
# fi
# ${UPDATE_KUBECONFIG_COMMAND}

# Save Inital Path
initial_path=$(pwd)


# Create folder in home directory
mkdir -p /home/$USER/.kube
cd /home/$USER/.kube

# Delete Config file if it exits
file=config
if [ -fe config ]
then 
    rm config
fi

# Creating File
config=""
echo "apiVersion: v1" > config
echo "clusters:" >> config  
echo "- cluster:" >> config
echo "    certificate-authority-data: ${CLUSTER_CERT}" >> config
echo "    server: ${SERVER}" >> config 
echo "  name: kubernetes" >> config  
echo "contexts:" >> config  
echo "- context:" >> config  
echo "    cluster: kubernetes" >> config  
echo "    namespace: $"{DEPLOY_NAMESPACE}" >> config 
echo "    user: aws" >> config  
echo "  name: aws" >> config  
echo "current-context: aws" >> config  
echo "kind: Config" >> config  
echo "preferences: {}" >> config  
echo "users:" >> config  
echo "- name: aws" >> config  
echo "  user:" >> config  
echo "    exec:" >> config  
echo "      apiVersion: client.authentication.k8s.io/v1alpha1" >> config  
echo "      args:" >> config  
echo "      - eks" >> config  
echo "      - get-token" >> config  
echo "      - --cluster-name" >> config  
echo "      - ${CLUSTER_NAME}" >> config
echo "      command: aws" >> config  
echo "      env: null" >> config  
echo "      interactiveMode: IfAvailable" >> config  
echo "      provideClusterInfo: false" >> config  

cd ${initial_path}

# Helm Dependency Update
helm dependency update ${DEPLOY_CHART_PATH:-helm/}

# Helm Deployment
UPGRADE_COMMAND="helm upgrade --wait --atomic --install --timeout ${TIMEOUT}"
for config_file in ${DEPLOY_CONFIG_FILES//,/ }
do
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -f ${config_file}"
done
if [ -n "$DEPLOY_NAMESPACE" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi
if [ -n "$DEPLOY_VALUES" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --set ${DEPLOY_VALUES}"
fi
if [ "$DEBUG" = true ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --debug"
fi
if [ "$DRY_RUN" = true ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --dry-run"
fi
UPGRADE_COMMAND="${UPGRADE_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH:-helm/}"
echo "Executing: ${UPGRADE_COMMAND}"
${UPGRADE_COMMAND}

rm -r /home/$USER/.kube 
