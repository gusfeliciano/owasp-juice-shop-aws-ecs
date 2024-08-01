
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

Create and Update your `.env.local` file with these IDs:

```
SECURITY_GROUP_ID=sg-xxxxxxxxxxxxxxxxx
SUBNET_IDS=subnet-xxxxxxxxxxxxxxxxx,subnet-yyyyyyyyyyyyyyyyy
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID
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

### 5. Task Definition

Update the `task-definition.json` file:

```json
{
  "family": "juice-shop-task",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole",
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


### 6. Deployment Script

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

Note: The `deploy.sh` script will automatically replace `${AWS_ACCOUNT_ID}` in the task definition with the actual AWS account ID from your `.env.local` file.

## Accessing the Deployed Juice Shop

After successful deployment, follow these steps to access your Juice Shop instance:

1. Go to the AWS ECS Console
2. Click on the "juice-shop-cluster"
3. In the "Tasks" tab, click on the running task
4. In the task details, find the "Public IP" under the "Network" section
5. Open a web browser and navigate to `http://<Public-IP>:3000`

Note: The IP address may change if the task is stopped and restarted. For a stable URL, consider setting up an Application Load Balancer.

## Cleanup

To avoid ongoing charges, remember to delete your AWS resources when you're done:

1. Delete the ECS service
2. Delete the ECS cluster
3. Delete the CloudWatch log group
4. Remove any created IAM roles and policies

## Troubleshooting

If you encounter issues:
1. Ensure your AWS CLI is correctly configured with the juice-shop profile
2. Check that all required IAM permissions are correctly set
3. Verify that your VPC, subnets, and security groups are correctly configured
4. Review CloudWatch logs for any application-specific errors

For any persistent issues, please open an issue in this repository.