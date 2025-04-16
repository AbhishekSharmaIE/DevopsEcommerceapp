#!/bin/bash

# Delete existing stack if it exists
aws cloudformation delete-stack --stack-name ecommerce-app-pipeline --region eu-west-1
aws cloudformation wait stack-delete-complete --stack-name ecommerce-app-pipeline --region eu-west-1

# Deploy new stack
aws cloudformation create-stack \
  --stack-name ecommerce-app-pipeline \
  --template-body file://cloudformation/pipeline.yml \
  --parameters \
    ParameterKey=GitHubOwner,ParameterValue=AbhishekSharmaIE \
    ParameterKey=GitHubRepo,ParameterValue=DevopsEcommerceapp \
    ParameterKey=GitHubBranch,ParameterValue=main \
  --capabilities CAPABILITY_IAM \
  --region eu-west-1

# Wait for stack creation
aws cloudformation wait stack-create-complete --stack-name ecommerce-app-pipeline --region eu-west-1

# Get stack outputs
aws cloudformation describe-stacks --stack-name ecommerce-app-pipeline --region eu-west-1 --query 'Stacks[0].Outputs' 