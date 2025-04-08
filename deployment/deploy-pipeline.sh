#!/bin/bash
set -e

# Create CloudFormation stack
echo "Creating CloudFormation stack..."
aws cloudformation create-stack \
  --stack-name ecommerce-app-pipeline \
  --template-body file://pipeline-template.yml \
  --parameters \
    ParameterKey=GitHubOwner,ParameterValue=AbhishekSharmaIE \
    ParameterKey=GitHubRepo,ParameterValue=DevopsEcommerceapp \
    ParameterKey=GitHubBranch,ParameterValue=main \
    ParameterKey=GitHubToken,ParameterValue=$GITHUB_TOKEN \
  --capabilities CAPABILITY_IAM

# Wait for stack creation
echo "Waiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name ecommerce-app-pipeline

# Get the pipeline status
echo "Pipeline creation completed. Checking status..."
aws codepipeline get-pipeline-state \
  --name ecommerce-app-pipeline

echo "Pipeline setup completed!" 