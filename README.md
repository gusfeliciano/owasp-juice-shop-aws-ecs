# OWASP Juice Shop on AWS ECS

## Introduction

This project deploys OWASP Juice Shop, an intentionally vulnerable web application, on Amazon Web Services (AWS) using Elastic Container Service (ECS) with Fargate. OWASP Juice Shop is a modern web application that includes a wide range of security flaws found in real-world applications. It's used by security professionals, developers, and students to learn about web application security in a safe, legal environment.

The purpose of this project is to:
1. Gain hands-on experience with AWS services and containerized application deployment
2. Understand and implement cloud security best practices
3. Provide a platform for practicing web application security testing

## Architecture

This project utilizes a microservices architecture deployed on AWS, leveraging several key services:

1. **Amazon ECS (Elastic Container Service)**: 
   - Manages and orchestrates our Docker containers
   - Uses Fargate launch type for serverless container management

2. **Amazon ECR (Elastic Container Registry)**:
   - Stores our Docker images securely

3. **Amazon VPC (Virtual Private Cloud)**:
   - Provides network isolation for our ECS tasks
   - Utilizes public and private subnets for enhanced security

4. **Application Load Balancer (ALB)**:
   - Distributes incoming application traffic across multiple targets
   - Enables HTTPS termination for secure communication

5. **Amazon CloudWatch**:
   - Monitors our ECS tasks and collects logs
   - Allows for setting up alarms and dashboards

6. **AWS Identity and Access Management (IAM)**:
   - Manages access to AWS services and resources securely

This architecture ensures scalability, security, and ease of management for our OWASP Juice Shop deployment.

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Docker installed
- jq installed (`sudo apt-get install jq` for Ubuntu/Debian or `brew install jq` for macOS)

## Setup Instructions

### 1. AWS IAM User and Policy Setup

1. Log in to the AWS Management Console
2. Navigate to IAM (Identity and Access Management)
3. In the left sidebar, click on "Users"
4. Click "Add user"
5. Set a username (e.g., "juice-shop-deployer")
6. Select "Programmatic access" for AWS CLI usage
7. Click "Next: Permissions"
8. Click "Attach existing policies directly"
9. Search for and select the following policies:
   - AmazonECS_FullAccess
   - AmazonEC2ContainerRegistryFullAccess
   - AmazonVPCFullAccess
   - CloudWatchLogsFullAccess
   - IAMFullAccess
   - ElasticLoadBalancingFullAccess
   - AWSCloudFormationFullAccess
   - AmazonEC2FullAccess
10. Click "Next: Tags" (you can skip adding tags for now)
11. Click "Next: Review"
12. Review the user details and click "Create user"
13. On the next page, you'll see the Access key ID and Secret access key. Download the .csv file or copy these credentials - you'll need them in the next step.

Now, let's create and attach the custom policy:

14. In the left sidebar of the IAM console, click on "Policies"
15. Click "Create policy"
16. Click on the "JSON" tab
17. Paste the following JSON:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:CreateCluster",
                "ecs:DeleteCluster",
                "ecs:DescribeClusters",
                "ecs:ListClusters",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:ListStacks",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ecs:RegisterTaskDefinition",
                "ecs:DeregisterTaskDefinition",
                "ecs:DescribeTaskDefinition",
                "ecs:ListTaskDefinitions",
                "ecs:CreateService",
                "ecs:DeleteService",
                "ecs:UpdateService",
                "ecs:DescribeServices"
            ],
            "Resource": "*"
        }
    ]
}
```

18. Click "Next: Tags" (you can skip adding tags)
19. Click "Next: Review"
20. Name the policy "JuiceShopCustomPolicy" and click "Create policy"
21. Go back to the user you created (juice-shop-deployer)
22. Under the "Permissions" tab, click "Add permissions"
23. Choose "Attach existing policies directly"
24. Search for "JuiceShopCustomPolicy" and select it
25. Click "Next: Review" and then "Add permissions"

### 2. AWS CLI Configuration

Configure a new AWS CLI profile for this project:

```bash
aws configure --profile juice-shop
```

Enter your AWS Access Key ID, Secret Access Key, default region (e.g., us-east-1), and preferred output format.

### 3. Network Setup

Before we can deploy our ECS tasks, we need to set up the necessary network resources.

#### Create a VPC

1. Go to the VPC dashboard in the AWS Management Console
2. Click "Create VPC"
3. Choose "VPC and more"
4. Configure the following:
   - Name tag auto-generation: Check this box
   - Name: juice-shop-vpc
   - IPv4 CIDR block: 10.0.0.0/16
   - Number of Availability Zones (AZs): 2
   - Number of public subnets: 2
   - Number of private subnets: 2
   - NAT gateways: In 1 AZ
   - VPC endpoints: None
5. Click "Create VPC"

#### Create a Security Group

1. In the VPC dashboard, click on "Security Groups" in the left sidebar
2. Click "Create security group"
3. Configure the following:
   - Security group name: juice-shop-sg
   - Description: Security group for Juice Shop ECS tasks
   - VPC: Select the VPC you just created (juice-shop-vpc)
4. In the "Inbound rules" section, click "Add rule" and set:
   - Type: Custom TCP
   - Port range: 3000
   - Source: Anywhere-IPv4 (0.0.0.0/0)
5. Click "Create security group"

#### Note the Resource IDs

After creating these resources, note down the following IDs. You'll need them for your `.env.local` file:

1. Security Group ID: Find this in the "Security Groups" section of the VPC dashboard
2. Subnet IDs: Go to "Subnets" in the VPC dashboard and note the IDs of the public subnets you created

Update your `.env.local` file with these IDs:

```
SECURITY_GROUP_ID=sg-xxxxxxxxxxxxxxxxx
SUBNET_IDS=subnet-xxxxxxxxxxxxxxxxx,subnet-yyyyyyyyyyyyyyyyy
AWS_REGION=us-east-1
```

Replace the placeholders with your actual resource IDs.


### 4. ECS Task Execution Role

Create the ECS Task Execution Role in the AWS Console:

1. In the IAM console, click on "Roles" in the left sidebar
2. Click "Create role"
3. Under "Select type of trusted entity", choose "AWS service"
4. Under "Choose a use case", select "Elastic Container Service"
5. Under "Select your use case", choose "Elastic Container Service Task"
6. Click "Next: Permissions"
7. Search for and select the "AmazonECSTaskExecutionRolePolicy"
8. Click "Next: Tags" (you can skip adding tags)
9. Click "Next: Review"
10. Set the Role name as "ecsTaskExecutionRole"
11. Click "Create role"

This role will be used by ECS to execute tasks on your behalf. You don't need to attach it to your IAM user; instead, you'll reference it in your task definition.

### 5. Environment Variables

Create a `.env.local` file in the project root with the following content:

```
SECURITY_GROUP_ID=sg-xxxxxxxxxxxxxxxxx
SUBNET_IDS=subnet-xxxxxxxxxxxxxxxxx,subnet-yyyyyyyyyyyyyyyyy
AWS_REGION=us-east-1
```

Replace the placeholders with your actual AWS resource IDs. Do not commit this file to version control.

### 6. Task Definition

Update the `task-definition.json` file:

```json
{
  "family": "juice-shop-task",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "juice-shop-container",
      "image": "bkimminich/juice-shop",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/juice-shop",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "256",
  "memory": "512"
}
```

Replace `YOUR_ACCOUNT_ID` with your actual AWS account ID. You can find your account ID by clicking on your account name in the top right corner of the AWS Management Console.

### 7. Deployment Script

Ensure the `deploy.sh` script is executable:

```bash
chmod +x deploy.sh
```

## Deployment

Run the deployment script:

```bash
./deploy.sh
```

This script will:
1. Create an ECS cluster (if it doesn't exist)
2. Register the task definition
3. Create or update the ECS service

## Accessing the Deployed Juice Shop

After successful deployment, follow these steps to access your Juice Shop instance:

1. Go to the AWS ECS Console
2. Click on the "juice-shop-cluster"
3. In the "Tasks" tab, click on the running task
4. In the task details, find the "Public IP" under the "Network" section
5. Open a web browser and navigate to `http://<Public-IP>:3000`

Note: The IP address may change if the task is stopped and restarted. For a stable URL, consider setting up an Application Load Balancer.

## Security Considerations

While OWASP Juice Shop is intentionally vulnerable for learning purposes, we implement several security measures in our AWS deployment:

1. **Network Security**:
   - Use of VPC with proper network segmentation
   - Security Groups to control inbound and outbound traffic
   - Private subnets for ECS tasks, with internet access through NAT Gateways

2. **Access Control**:
   - IAM roles and policies following the principle of least privilege
   - No hard-coded AWS credentials in our codebase

3. **Data in Transit**:
   - HTTPS enabled on ALB with AWS Certificate Manager

4. **Monitoring and Logging**:
   - CloudWatch for centralized logging and monitoring
   - CloudTrail for AWS API call history and security analysis

5. **Container Security**:
   - Regular updates of the OWASP Juice Shop image
   - Scanning Docker images for vulnerabilities before deployment

6. **Compliance**:
   - Tagging strategy for resource tracking and cost allocation

Note: As OWASP Juice Shop is intentionally vulnerable, it should never be deployed in a production environment or connected to any sensitive systems or data.

## Cleanup

To avoid ongoing charges, remember to delete your AWS resources when you're done:

1. Delete the ECS service
2. Delete the ECS cluster
3. Delete the CloudWatch log group
4. Remove any created IAM roles and policies

## Learning Outcomes

Through this project, you will gain hands-on experience and knowledge in:

1. **Container Orchestration**: 
   - Deploying and managing Docker containers using Amazon ECS
   - Understanding the benefits of serverless container management with Fargate

2. **Infrastructure as Code (IaC)**:
   - Using AWS CLI and shell scripts to automate deployment
   - (Future improvement: Implementing Terraform or AWS CloudFormation)

3. **Cloud Security**:
   - Implementing security best practices in AWS
   - Understanding the shared responsibility model in cloud security

4. **Networking in AWS**:
   - Configuring VPCs, subnets, and security groups
   - Setting up public-facing applications securely

5. **CI/CD Practices**:
   - (Future improvement: Implementing a CI/CD pipeline with GitHub Actions)

6. **Monitoring and Logging**:
   - Utilizing CloudWatch for application and infrastructure monitoring

7. **Web Application Security**:
   - Gaining hands-on experience with OWASP Juice Shop, understanding common web vulnerabilities

8. **Cost Optimization**:
   - Understanding AWS pricing models and how to optimize costs in cloud deployments

This project serves as a practical demonstration of deploying and securing a cloud-native application, showcasing both DevOps and security skills valuable in modern software development and operations.

## Troubleshooting

If you encounter issues:
1. Ensure your AWS CLI is correctly configured with the juice-shop profile
2. Check that all required IAM permissions are correctly set
3. Verify that your VPC, subnets, and security groups are correctly configured
4. Review CloudWatch logs for any application-specific errors

For any persistent issues, please open an issue in this repository.