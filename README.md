# OWASP Juice Shop on AWS ECS

This project deploys OWASP Juice Shop, an intentionally vulnerable web application, on AWS using Elastic Container Service (ECS) with Fargate.

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Docker installed

## Deployment Steps

1. Clone this repository
2. Configure AWS resources as described in the setup instructions
3. Run `./deploy.sh`

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

## Learning Outcomes

Through this project, I have gained hands-on experience and knowledge in:

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