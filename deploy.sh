#!/bin/bash

# Load environment variables
source .env.local

# Set AWS profile
export AWS_PROFILE=juice-shop

# Variables
CLUSTER_NAME="juice-shop-cluster"
SERVICE_NAME="juice-shop-service"
TASK_FAMILY="juice-shop-task"

# Check if cluster exists
CLUSTER_STATUS=$(aws ecs describe-clusters --clusters $CLUSTER_NAME --query 'clusters[0].status' --output text --region $AWS_REGION)

if [ "$CLUSTER_STATUS" != "ACTIVE" ]; then
  echo "Creating ECS cluster..."
  aws ecs create-cluster --cluster-name $CLUSTER_NAME --region $AWS_REGION
else
  echo "Cluster already exists, skipping creation."
fi

# Register the task definition
echo "Registering task definition..."
# Replace AWS_ACCOUNT_ID in task definition
sed "s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g" task-definition.json > task-definition-temp.json
TASK_DEFINITION=$(aws ecs register-task-definition --cli-input-json file://task-definition-temp.json --region $AWS_REGION)
TASK_REVISION=$(echo $TASK_DEFINITION | jq --raw-output '.taskDefinition.revision')
rm task-definition-temp.json

# Check if service exists
SERVICE_STATUS=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --query 'services[0].status' --output text --region $AWS_REGION)

if [ "$SERVICE_STATUS" == "ACTIVE" ]; then
  echo "Updating existing service..."
  aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition ${TASK_FAMILY}:${TASK_REVISION} \
    --region $AWS_REGION
else
  echo "Creating new service..."
  aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition ${TASK_FAMILY}:${TASK_REVISION} \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --region $AWS_REGION
fi

echo "Deployment completed!"