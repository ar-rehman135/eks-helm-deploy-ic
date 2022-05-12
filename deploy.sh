#!/bin/sh


# Login to Kubernetes Cluster.
# UPDATE_KUBECONFIG_COMMAND="aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
# if [ -n "$CLUSTER_ROLE_ARN" ]; then
#     UPDATE_KUBECONFIG_COMMAND="${UPDATE_KUBECONFIG_COMMAND} --role-arn=${CLUSTER_ROLE_ARN}"
# fi
# ${UPDATE_KUBECONFIG_COMMAND}

# echo "CURRENT DIR:"
# pwd

# echo "CURRENT Files:"
# ls -al


aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set region $AWS_REGION



# Save Inital Path
initial_path=$(pwd)


# Create folder in home directory
mkdir -p /home/kube
echo "Kube DIR : " "/home/kube/config"
cd /home/kube

# Delete Config file if it exits
file='config'
if [ -f $file ]
then 
	echo "Removing $file"
    	rm $file
fi

# echo "SERVER Var:" $SERVER

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
echo "    namespace: ${DEPLOY_NAMESPACE}" >> config 
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



chmod g-r config
chmod o-r config
ls -al ${initial_path}

echo "Check KUBECONFIG------------------------"
export KUBECONFIG='/home/kube/config'
# echo $KUBECONFIG
# echo "KubeConfig"
# cat $KUBECONFIG

# echo "Check AWS------------------------"
# tree -L 4 -a /github
# cat /github/home/.aws/config
# cat /github/home/.aws/credentials
# echo "------------------------"


# echo "Print Secrets-------------------------"
# echo $AWS_ACCESS_KEY_ID | sed 's/./& /g'
# echo $AWS_SECRET_ACCESS_KEY | sed 's/./& /g'
# echo $CLUSTER_NAME | sed 's/./& /g'
# echo $CLUSTER_CERT | sed 's/./& /g'
# echo $SERVER | sed 's/./& /g'
# echo "Print Secrets-------------------------"


echo "Check Software------------------------"
aws --version
kubectl version
helm version
# apt-get install tree
echo "------------------------"


# echo $(pwd)

# Helm Deployment
UPGRADE_COMMAND="helm upgrade --install --timeout 30s"
for config_file in ${DEPLOY_CONFIG_FILES}
do
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -f ${config_file}"
done
if [ -n "$DEPLOY_NAMESPACE" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} -n ${DEPLOY_NAMESPACE}"
fi
if [ -n "$DEPLOY_VALUES" ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --set ${DEPLOY_VALUES}"
fi
# if [ false ]; then
#     UPGRADE_COMMAND="${UPGRADE_COMMAND} --debug"
# fi
if [ "$DRY_RUN" = true ]; then
    UPGRADE_COMMAND="${UPGRADE_COMMAND} --dry-run"
fi
UPGRADE_COMMAND="${UPGRADE_COMMAND} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH}"
echo "Executing: ${UPGRADE_COMMAND}"
${UPGRADE_COMMAND}


rm -r /home/kube 