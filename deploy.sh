#!/bin/bash

# Register the task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create an ECS cluster
aws ecs create-cluster --cluster-name juice-shop-cluster

# Create a service
aws ecs create-service \
  --cluster juice-shop-cluster \
  --service-name juice-shop-service \
  --task-definition juice-shop-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678]}"

# Note: Replace subnet-12345678 and sg-12345678 with your actual subnet and security group IDs