# OWASP Juice Shop on AWS ECS

## Introduction

This project deploys OWASP Juice Shop, an intentionally vulnerable web application, on Amazon Web Services (AWS) using Elastic Container Service (ECS) with Fargate. OWASP Juice Shop is a modern web application that includes a wide range of security flaws found in real-world applications. It's used by security professionals, developers, and students to learn about web application security in a safe, legal environment.

The purpose of this project is to:
1. Gain hands-on experience with AWS services and containerized application deployment
2. Understand and implement cloud security best practices
3. Provide a platform for practicing web application security testing
4. Document the process of solving OWASP Juice Shop challenges
5. Provide a comprehensive resource for others learning about web application security and cloud deployment

## Table of Contents

- [Setup Instructions](SETUP.md)
- [Architecture Overview](#architecture-overview)
- [Prerequisites](#Prerequisites)
- [Learning Outcomes](#learning-outcomes)
- [Juice Shop Exercises](#juice-shop-exercises)

## Architecture Overview

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

## Juice Shop Exercises

Here's a list of the Juice Shop exercises I've completed, with links to detailed write-ups:

1. [Exercise 1: Finding the Score Board](exercises/exercise1.md)
2. TBD
<!-- Add more exercises as you complete them -->