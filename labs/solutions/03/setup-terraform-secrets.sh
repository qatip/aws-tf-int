#!/bin/bash

# Define Variables
AWS_REGION="us-east-1"
IAM_USER="terraform-user"
SECRET_NAME="terraform-aws-credentials"

# Create an IAM user
aws iam create-user --user-name $IAM_USER

# Attach necessary permissions
aws iam attach-user-policy --user-name $IAM_USER --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create Access Keys
CREDS=$(aws iam create-access-key --user-name $IAM_USER)

# Extract Access Key and Secret Key
ACCESS_KEY=$(echo $CREDS | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo $CREDS | jq -r '.AccessKey.SecretAccessKey')

# Store in AWS Secrets Manager
aws secretsmanager create-secret --name $SECRET_NAME --secret-string "{\"aws_access_key_id\":\"$ACCESS_KEY\", \"aws_secret_access_key\":\"$SECRET_KEY\"}"

echo "AWS credentials stored in Secrets Manager under secret name: $SECRET_NAME"
